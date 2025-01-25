class_name Projectile
extends Node3D

@export var direction: Vector3
@export var speed: float = 20.0
@export var damage: int = 30
var velocity: Vector3 = Vector3.ZERO


func set_velocity(new_velocity: Vector3):
	velocity = new_velocity

func _physics_process(delta: float) -> void:
	translate(velocity * delta)

	if not is_inside_tree():
		return

	if global_position.length() > 1000:
		queue_free()

	if direction:
		set_velocity(direction * speed)

func _on_area_entered(_area):
	queue_free()

func _on_area_3d_body_entered(body: Node3D):
	if body is Enemy:
		body.deal_damage(damage)
		queue_free()
