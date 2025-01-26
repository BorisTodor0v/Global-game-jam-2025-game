class_name PowerUp
extends Node3D

@export var effect_duration: float = 15.0
@export var model: Node3D

func _on_area_entered(body: Node3D):
	if body.is_in_group("player"):
		apply_powerup(body)
		queue_free()

func apply_powerup(_player: Node3D):
	pass
