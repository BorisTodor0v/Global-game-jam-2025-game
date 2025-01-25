extends Node3D

@onready var enemy_manager = $Enemies

var score: int = 0;

func _ready() -> void:
	enemy_manager.connect("increment_score", increment_score)


func increment_score():
	score += 100
	print_debug("current score: ", score)
