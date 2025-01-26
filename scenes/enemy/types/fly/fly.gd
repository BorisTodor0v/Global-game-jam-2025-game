extends Enemy

@onready var animation_player : AnimationPlayer = $fly/AnimationPlayer

func _ready():
	speed = 3.0
	animation_player.play("Fly")

func deal_damage(damage: int):
	health -= damage
	if health <= 0:
		death.emit()
