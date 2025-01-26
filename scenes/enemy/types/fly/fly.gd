extends Enemy

@onready var animation_player : AnimationPlayer = $wanderer/AnimationPlayer

func _ready():
	animation_player.play("Fly")
