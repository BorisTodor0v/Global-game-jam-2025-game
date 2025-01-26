extends Node3D

signal bacteria_death

@export var floor_checkpoints: Node3D
@export var table_checkpoints: Node3D
@export var floor_nav_agent_holder: Node3D
@export var table_nav_agent_holder: Node3D

@onready var bacteria_scene = preload("res://scenes/enemy/types/wanderer/wanderer.tscn")
var max_bacteria_at_once: int = 10
var current_number_of_bacteria: int = 0
@export var bacteria_spawn_timer: float = 2.0
var bacteria_spawn_time_elapsed: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_number_of_bacteria < max_bacteria_at_once:
		bacteria_spawn_time_elapsed += delta
		if bacteria_spawn_time_elapsed >= bacteria_spawn_timer:
			spawn_bacteria()
			bacteria_spawn_time_elapsed = 0

func spawn_bacteria():
	var wanderer = bacteria_scene.instantiate()
	var spawn_node: Marker3D
	var destination_node: Marker3D
	
	var spawn_location: int = randi_range(0, 1)
	
	match spawn_location:
		0: # Table
			spawn_node = table_checkpoints.get_child(randi_range(0, table_checkpoints.get_child_count() - 1))
			destination_node = table_checkpoints.get_child(randi_range(0, table_checkpoints.get_child_count() - 1))
			table_nav_agent_holder.add_child(wanderer)
			pass
		1: # Floor
			spawn_node = floor_checkpoints.get_child(randi_range(0, floor_checkpoints.get_child_count() - 1))
			destination_node = floor_checkpoints.get_child(randi_range(0, floor_checkpoints.get_child_count() - 1))
			floor_nav_agent_holder.add_child(wanderer)
			pass
		_:
			pass
	
	wanderer.global_transform = spawn_node.global_transform
	wanderer.destination = destination_node
	current_number_of_bacteria += 1
	wanderer.connect("death", death)
	wanderer.connect("destination_reached", assign_new_destination.bind(wanderer))

func death():
	bacteria_death.emit()
	current_number_of_bacteria -= 1

func assign_new_destination(bacteria: Enemy):
	var destination_node
	match bacteria.get_parent().name:
		"Floor":
			destination_node = floor_checkpoints.get_child(randi_range(0, floor_checkpoints.get_child_count() - 1))
		"Table":
			destination_node = table_checkpoints.get_child(randi_range(0, table_checkpoints.get_child_count() - 1))
		_:
			pass
	bacteria.destination = destination_node
