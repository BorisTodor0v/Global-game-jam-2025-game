extends Node3D

signal increment_score

#@export var enemy_spawn_point: Marker3D
#@export var enemy_scene: PackedScene
#
#@onready var enemy_container = $"."

@export var fly_spawner: Node3D
@export var bacteria_spawner: Node3D

var score := 0
#var spawn_timer: float = 0.0
#
#const SPAWN_INTERVAL := 5.0

func _ready():
	fly_spawner.connect("fly_death", increment_score.emit)
	bacteria_spawner.connect("bacteria_death", increment_score.emit)
	#if not enemy_scene:
		#enemy_scene = preload("res://scenes/enemy/enemy.tscn")

#func _process(delta):
	#spawn_timer += delta
	#if spawn_timer >= SPAWN_INTERVAL:
		#spawn_enemy()
		#spawn_timer = 0
#
#func spawn_enemy():
	#var enemy = enemy_scene.instantiate()
	#enemy_container.add_child(enemy)
	#enemy.connect("death", increment_score.emit)
	#
	#enemy.global_position = enemy_spawn_point.global_position
