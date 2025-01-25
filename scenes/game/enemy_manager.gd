extends Node3D

signal increment_score

@export var enemy_spawn_point: Marker3D
@export var enemy_scene: PackedScene

@onready var enemy_container = $"."

var score := 0
var spawn_timer: float = 0.0

const SPAWN_INTERVAL := 5.0

func _ready():
	if not enemy_scene:
		enemy_scene = preload("res://scenes/enemy/enemy.tscn")

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_enemy()
		spawn_timer = 0

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy_container.add_child(enemy)
	enemy.connect("death", increment_score.emit)
	
	enemy.global_position = enemy_spawn_point.global_position
