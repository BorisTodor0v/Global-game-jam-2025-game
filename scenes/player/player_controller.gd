extends CharacterBody3D

@onready var camera_spring: SpringArm3D = $CamRoot/SpringArm3D
@onready var camera: Camera3D = $CamRoot/SpringArm3D/Camera3D

@export var blaster: Blaster;

const MOUSE_SENSITIVITY = 0.005
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ZOOM_FOV = 45.0
const DEFAULT_FOV = 70.0
const PROJECTILE_SPEED = 20

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_zooming = false

var projectile_scene = preload("res://scenes/projectile/projectile.tscn")

func _input(_event):
	if Input.is_action_just_pressed("shoot"):
		shoot_projectile()
	if Input.is_action_pressed("aim"):
		is_zooming = true
	else:
		is_zooming = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	camera.fov = lerp(camera.fov, ZOOM_FOV if is_zooming else DEFAULT_FOV, 10 * delta)

func shoot_projectile():
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = blaster.projectile_position.global_position
	var shoot_direction = -camera.global_transform.basis.z.normalized()

	if projectile.has_method("set_velocity"):
		projectile.set_velocity(shoot_direction * PROJECTILE_SPEED)
