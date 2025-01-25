extends CharacterBody3D

@onready var camera_spring: SpringArm3D = $CamRoot/SpringArm3D
@onready var camera: Camera3D = $CamRoot/SpringArm3D/Camera3D
@onready var animation_player = $player_v1/AnimationPlayer
@onready var visuals = $player_v1
@onready var grapplecast = $CamRoot/SpringArm3D/Camera3D/GrappleCast
@onready var player: Node3D = get_parent()

@export var blaster: Blaster;
@export var rope: Node3D

const MOUSE_SENSITIVITY = 0.005
const DEFAULT_FOV = 70.0
const ZOOM_FOV = 45.0
const JUMP_VELOCITY = 4.5
const PROJECTILE_SPEED = 20
const FIRE_RATE = 0.2
const WALK_SPEED = 5.0
const SPRINT_SPEED = 15.0

var speed := WALK_SPEED
var gravity: float

var is_sprinting = false
var is_zooming = false

var last_shot_time = 0.0
var projectile_scene: PackedScene

var grappling = false
var hookpoint = Vector3()
var hookpoint_get = false

# mouse lock
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	projectile_scene = preload("res://scenes/projectile/projectile.tscn")


func _input(_event):
	is_zooming = Input.is_action_pressed("aim")


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
			_rotate_camera(event)

# movement
func _physics_process(delta):
	_handle_grapple()
	_handle_movement(delta)
	_handle_shooting()
	_update_animaton()

	_process_movement_input()
	move_and_slide()

	camera.fov = lerp(camera.fov, ZOOM_FOV if is_zooming else DEFAULT_FOV, 10 * delta)

func _rotate_camera(event: InputEventMouseMotion) -> void:
	self.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
	camera_spring.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
	camera_spring.rotation.x = clamp(camera_spring.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func shoot_projectile():
	var projectile = projectile_scene.instantiate()
	projectile.direction = -camera.global_transform.basis.z.normalized()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = blaster.projectile_position.global_position


func _handle_grapple():
	if Input.is_action_just_pressed("grapple"):
		if grapplecast.is_colliding():
			print_debug(grapplecast.get_collider())
			if not grappling:
				grappling = true
	if grappling:
		velocity.y = 0
		if not hookpoint_get:
			hookpoint = grapplecast.get_collision_point() + Vector3(0, 0.1, 0)
			hookpoint_get = true
		if hookpoint.distance_to(transform.origin) > 1:
			if hookpoint_get:
				transform.origin = lerp(transform.origin, hookpoint, 0.015)
		else:
			grappling = false
			hookpoint_get = false
			
	update_rope()

func update_rope():
	if !grappling:
		rope.visible = false
		return
		
	rope.visible = true
	var dist = player.global_position.distance_to(hookpoint)
	rope.scale.y = dist
	
	rope.look_at(hookpoint)
	rope.scale = Vector3(1, 1, dist)

func _handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	is_sprinting = Input.is_action_pressed("sprint")
	speed = SPRINT_SPEED if is_sprinting else WALK_SPEED

func _handle_shooting():
	if Input.is_action_pressed("shoot"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_shot_time >= FIRE_RATE:
			shoot_projectile();
			last_shot_time = current_time

func _process_movement_input() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		visuals.look_at(position - direction)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

func _update_animaton() -> void:
	if velocity.length() > 0:
		animation_player.play("Sprint" if is_sprinting else "Stand - Walk")
	else:
		animation_player.play("Stand - Idle")
