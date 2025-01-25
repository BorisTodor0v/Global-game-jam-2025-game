class_name Enemy
extends CharacterBody3D

signal death

@export var health: int = 100

const SPEED = 1
var move_timer: float = 0
const DIRECTION_CHANGE_TIME: float = 1.0

func _physics_process(delta):
	move_timer += delta
	if move_timer >= DIRECTION_CHANGE_TIME:
		_change_direction()
		move_timer = 0
	
	move_and_slide()

func _change_direction():
	var random_direction = Vector3(
		randf_range(-1, 1),
		0,
		randf_range(-1, 1)
	).normalized()
	
	velocity = random_direction * SPEED

func deal_damage(damage: int):
	health -= damage

	if health <= 0:
		death.emit()
		queue_free()
