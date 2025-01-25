class_name Projectile
extends Node3D

@export var speed: float = 20.0
var velocity: Vector3 = Vector3.ZERO

func set_velocity(new_velocity: Vector3):
	velocity = new_velocity

func _physics_process(delta: float) -> void:
	translate(velocity * delta)

	if not is_inside_tree():
		return

	if global_position.length() > 1000:
		queue_free()

func _on_area_entered(_area):
	queue_free()

func _on_area_3d_body_entered(_body: Node3D):
	print_debug("Hit something")
	queue_free()
