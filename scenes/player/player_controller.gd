extends CharacterBody3D

@onready var camera_spring: SpringArm3D = $CamRoot/SpringArm3D
@onready var camera: Camera3D = $CamRoot/SpringArm3D/Camera3D
@onready var animation_player = $player_v1/AnimationPlayer
@onready var visuals = $player_v1

@onready var grapplecast = $GrappleCast


@export var blaster: Blaster;

const MOUSE_SENSITIVITY = 0.005
const DEFAULT_FOV = 70.0
const ZOOM_FOV = 45.0
const JUMP_VELOCITY = 4.5
const PROJECTILE_SPEED = 20

var speed = 5.0
var WALK_SPEED = 5.0
var SPRINT_SPEED = 15.0
var is_sprinting = false
var is_zooming = false

var gravity
var projectile_scene = preload("res://scenes/projectile/projectile.tscn")

var grappling = false
var hookpoint = Vector3()
var hookpoint_get = false

# mouse lock
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _input(_event):
	if Input.is_action_just_pressed("shoot"):
		shoot_projectile()
	if Input.is_action_pressed("aim"):
		is_zooming = true
	else:
		is_zooming = false


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			self.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			camera_spring.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			camera_spring.rotation.x = clamp(camera_spring.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func grapple():
	if Input.is_action_just_pressed("grapple"):
		if grapplecast.is_colliding():
			print_debug(grapplecast.get_collider())
			if not grappling:
				grappling = true
	if grappling:
		velocity.y = 0
		if not hookpoint_get:
			hookpoint = grapplecast.get_collision_point() + Vector3(0, 0.5, 0)
			hookpoint_get = true
		if hookpoint.distance_to(transform.origin) > 1:
			if hookpoint_get:
				transform.origin = lerp(transform.origin, hookpoint, 0.05)
		else:
			grappling = false
			hookpoint_get = false

# movement
func _physics_process(delta):
	grapple()
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		is_sprinting = true
	else:
		speed = WALK_SPEED
		is_sprinting = false

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_sprinting:
			if animation_player.current_animation != "Sprint":
				animation_player.play("Sprint")
		else:
			if animation_player.current_animation != "Stand - Walk":
				animation_player.play("Stand - Walk")
		
		visuals.look_at(position - direction)
		
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if animation_player.current_animation != "Stand - Idle":
			animation_player.play("Stand - Idle")
		
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()

	camera.fov = lerp(camera.fov, ZOOM_FOV if is_zooming else DEFAULT_FOV, 10 * delta)

func shoot_projectile():
	var projectile = projectile_scene.instantiate()
	projectile.direction = -camera.global_transform.basis.z.normalized()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = blaster.projectile_position.global_position
