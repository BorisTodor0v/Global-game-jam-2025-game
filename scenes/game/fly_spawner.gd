extends Node3D

@onready var fly_scene = preload("res://scenes/enemy/types/fly/fly.tscn")
var max_flies_at_once : int = 10
@export var fly_spawn_timer : float = 5.0
var fly_spawn_time_elapsed : float = 0
@export var fly_paths : Array[Path3D]
var flies : Array[Enemy]

signal fly_death

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if flies.size() < max_flies_at_once:
		fly_spawn_time_elapsed += delta
		if fly_spawn_time_elapsed >= fly_spawn_timer:
			spawn_fly()
			fly_spawn_time_elapsed = 0
	
	for fly in flies:
		if fly.health > 0:
			var path_follow_parent : PathFollow3D = fly.get_parent()
			path_follow_parent.progress += delta * fly.speed
		else:
			flies.remove_at(fly.get_index())

func spawn_fly():
	var path_index : int = randi_range(0, fly_paths.size()-1)
	var fly_path_follow : PathFollow3D = PathFollow3D.new()
	fly_path_follow.rotation_mode = PathFollow3D.ROTATION_XYZ
	fly_path_follow.use_model_front = true
	var fly = fly_scene.instantiate()
	fly.connect("death", remove_fly.bind(fly))
	fly.connect("death", fly_death.emit)
	flies.append(fly)
	fly_path_follow.add_child(fly)
	fly_paths[path_index].add_child(fly_path_follow)

func remove_fly(fly : Enemy):
	flies.erase(fly)
	fly.queue_free()
