class_name Player
extends CharacterBody3D

@onready var camera_spring: SpringArm3D = $CamRoot/SpringArm3D
@onready var camera: Camera3D = $CamRoot/SpringArm3D/Camera3D
@onready var visuals = $player_v3
@onready var grapplecast = $CamRoot/SpringArm3D/Camera3D/GrappleCast
@onready var aim_raycast: RayCast3D = $CamRoot/SpringArm3D/Camera3D/AimRaycast
@onready var player: Node3D = get_parent()

@export var blaster: Blaster
@export var rope: Node3D
@export var power_up_bubble: MeshInstance3D
var power_up_bubble_material: Material
@export var effect_duration_timer: Timer
@export var hud: HUD

const MOUSE_SENSITIVITY = 0.005
const DEFAULT_FOV = 70.0
const ZOOM_FOV = 45.0
const JUMP_VELOCITY = 4.5
const PROJECTILE_SPEED = 20
const FIRE_RATE = 0.13
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

var speed_multiplier: float = 1.0

@export var animation_blend_speed: float = 15

@export var animation_tree: AnimationTree
# AnimationTree blend values (BETWEEN 0 AND 1)
var animation_blend_values: Dictionary = {
	#"idle" - not in here because if all other values are 0, the animation played will be the idle animation
	"walk" = 0.0,
	"run" = 0.0,
	"sprint" = 0.0,
	"jump" = 0.0,
	"grapple" = 0.0,
	"fall" = 0.0,
	"aim" = 0.0
}
var current_animation: String = "idle"

var power_up_bubble_colors: Dictionary = {
	"double_damage": {
		"base_color" = Vector4(0.5, 0.0, 0.0, 1.0),
		"pulse_color" = Vector4(1.0, 0.0, 0.0, 1.0)
	},
	"speed_up": {
		"base_color" = Vector4(0.0, 0.5, 1.0, 1.0),
		"pulse_color" = Vector4(0.5, 0.7, 1.0, 1.0)
	}
}

# mouse lock
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	projectile_scene = preload("res://scenes/projectile/projectile.tscn")
	power_up_bubble_material = power_up_bubble.get_active_material(0)
	print_debug(power_up_bubble_material)
	#add_to_group("player")

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
	_update_animation(delta)

	_process_movement_input()
	move_and_slide()

	camera.fov = lerp(camera.fov, ZOOM_FOV if is_zooming else DEFAULT_FOV, 10 * delta)

func _process(_delta):
	if Input.is_action_pressed("aim"):
		is_zooming = true
	
	if Input.is_action_just_released("aim"):
		is_zooming = false

func _rotate_camera(event: InputEventMouseMotion) -> void:
	self.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
	camera_spring.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
	camera_spring.rotation.x = clamp(camera_spring.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
func shoot_projectile():
	var projectile = projectile_scene.instantiate()
	
	var shoot_direction = -camera.global_transform.basis.z
	
	projectile.direction = shoot_direction
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = camera.global_position + shoot_direction

func _handle_grapple():
	if Input.is_action_just_pressed("grapple"):
		if grapplecast.is_colliding():
			grappling = !grappling
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
		visuals.look_at(hookpoint)
		visuals.global_rotation.x = deg_to_rad(0)
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
		current_animation = "jump"
		velocity.y = JUMP_VELOCITY

	is_sprinting = Input.is_action_pressed("sprint") and !is_zooming
	speed = SPRINT_SPEED if is_sprinting else WALK_SPEED

func _handle_shooting():
	if Input.is_action_pressed("shoot"):
		if is_zooming:
			
			# Delay between shots
			var current_time = Time.get_ticks_msec() / 1000.0
			if current_time - last_shot_time >= FIRE_RATE:
				shoot_projectile();
				last_shot_time = current_time

func set_speed_multiplier(value: float):
	speed_multiplier = value

func _process_movement_input() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		if is_zooming:
			# when aiming, face forward
			var aim_direction = camera.global_transform.basis.z
			aim_direction.y = 0 # Keep character upright
			aim_direction = aim_direction.normalized()
			visuals.global_transform.basis = Basis.looking_at(aim_direction)
		else:
			# when not aiming, face in movement direction
			visuals.look_at(position - direction)
		velocity.x = direction.x * speed * speed_multiplier
		velocity.z = direction.z * speed * speed_multiplier
	else:
		if is_zooming:
			var aim_direction = camera.global_transform.basis.z
			aim_direction.y = 0
			aim_direction = aim_direction.normalized()
			visuals.global_transform.basis = Basis.looking_at(aim_direction)
			
		velocity.x = 0.0
		velocity.z = 0.0

func _update_animation(delta) -> void:
	
	# Determine what animation state is currently active
	if velocity.length() > 0:
		if is_on_floor():
			if is_zooming:
				current_animation = "aim"
			else:
				current_animation = "sprint" if is_sprinting else "walk"
		else:
			if grappling:
				current_animation = "grapple"
			else:
				current_animation = "fall"
	else:
		current_animation = "aim" if is_zooming else "idle"
	
	# Update blend values
	for animation in animation_blend_values.keys():
		if animation == current_animation:
			animation_blend_values[animation] = lerp(animation_blend_values[animation], 1.0, animation_blend_speed * delta)
		else:
			animation_blend_values[animation] = lerp(animation_blend_values[animation], 0.0, animation_blend_speed * delta)
	
	# Update AnimationTree blend values
	animation_tree["parameters/WalkBlend/blend_amount"] = animation_blend_values["walk"]
	animation_tree["parameters/RunBlend/blend_amount"] = animation_blend_values["run"]
	animation_tree["parameters/SprintBlend/blend_amount"] = animation_blend_values["sprint"]
	animation_tree["parameters/JumpBlend/blend_amount"] = animation_blend_values["jump"]
	animation_tree["parameters/GrappleBlend/blend_amount"] = animation_blend_values["grapple"]
	animation_tree["parameters/FallBlend/blend_amount"] = animation_blend_values["fall"]
	animation_tree["parameters/AimBlend/blend_amount"] = animation_blend_values["aim"]

func show_power_up_bubble(status_upgrade: String, effect_duration: float):
	match status_upgrade:
		"double_damage":
			power_up_bubble_material.set_shader_parameter("base_color", power_up_bubble_colors["double_damage"]["base_color"])
			power_up_bubble_material.set_shader_parameter("pulse_color", power_up_bubble_colors["double_damage"]["pulse_color"])
		"speed_up":
			power_up_bubble_material.set_shader_parameter("base_color", power_up_bubble_colors["speed_up"]["base_color"])
			power_up_bubble_material.set_shader_parameter("pulse_color", power_up_bubble_colors["speed_up"]["pulse_color"])
			set_speed_multiplier(2.0)
		_:
			pass
	power_up_bubble.show()
	effect_duration_timer.wait_time = effect_duration
	effect_duration_timer.start()

func hide_power_up_bubble():
	power_up_bubble.hide()
	set_speed_multiplier(1.0)
