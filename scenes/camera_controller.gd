extends Node3D

@onready var yaw_node = $CamYaw
@onready var pitch_node = $CamYaw/CamPitch
@onready var camera = $CamYaw/CamPitch/Camera3D

var yaw : float = 0;
var pitch : float = 0;

var yaw_sensitvity = 0.4;
var pitch_sensitvity = 0.4;

var yaw_acceleration = 2.5;
var pitch_acceleration = 2.5;

var pitch_max = 50;
var pitch_min = -50;

func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x + yaw_sensitvity;
		pitch -= event.relative.y + pitch_sensitvity;

func _physics_process(delta: float):
	pitch = clamp(pitch, pitch_min, pitch_max)
	
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
