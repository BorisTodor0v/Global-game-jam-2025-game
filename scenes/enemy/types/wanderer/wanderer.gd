extends Enemy

@onready var animation_player : AnimationPlayer = $wanderer/AnimationPlayer
@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@export var destination : Node3D
@export var acceleration : float = 2.0

func _ready():
	animation_player.play("Moving")

func _physics_process(delta):
	if destination:
		nav_agent.target_position = destination.global_position
		var direction = nav_agent.target_position - global_transform.origin
		direction = direction.normalized()
		velocity = velocity.lerp(direction*speed, acceleration*delta)
		rotation.y = atan2(-velocity.x,-velocity.z) # Rotates to face movement direction
		move_and_slide()
		if global_transform.origin.distance_to(nav_agent.target_position) < 2.0:
			destination = null
