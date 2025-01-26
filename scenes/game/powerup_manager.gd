extends Node3D

@export var powerup_scenes: Array[PackedScene]

var spawn_timer := 0.0
const SPAWN_INTERVAL := 15.0

func _ready():
	if powerup_scenes.is_empty():
		var double_damage = preload("res://scenes/powerup/double_damage/double_damage.tscn")
		var speed_up = preload("res://scenes/powerup/speed_up/speed_up.tscn")
		powerup_scenes = [double_damage, speed_up]

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_powerup()
		spawn_timer = 0

func spawn_powerup():
	# rand powerup
	var random_index = randi() % powerup_scenes.size()
	var powerup = powerup_scenes[random_index].instantiate()
	add_child(powerup)
	
	# rand position
	var spawn_area = 10.0
	var random_x = randf_range(-spawn_area, spawn_area)
	var random_z = randf_range(-spawn_area, spawn_area)
	
	powerup.global_position = Vector3(random_x, 0, random_z)
