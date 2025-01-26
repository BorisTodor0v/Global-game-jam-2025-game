extends Node3D

@export var enemy_manager: Node3D
@export var combo_manager: ComboManager
@export var player: Player

var score: float = 0;

func _ready() -> void:
	enemy_manager.connect("increment_score", on_enemy_killed)
	combo_manager.connect("combo_updated", _on_combo_updated)
	combo_manager.connect("combo_timer_updated", _on_combo_timer_updated)

func on_enemy_killed():
	var points = 100 * combo_manager.calculate_multiplier()
	player.hud.show_points_gained(points)
	await get_tree().create_timer(0.5).timeout
	score += points
	player.hud.update_score(score)
	combo_manager.on_enemy_killed()

func _on_combo_updated(combo: int, multiplier: float):
	player.hud.update_combo(combo, multiplier)

func _on_combo_timer_updated(time_left: float, max_time: float):
	player.hud.update_timer(time_left, max_time)
