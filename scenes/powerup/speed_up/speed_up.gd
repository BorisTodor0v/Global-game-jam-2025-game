extends PowerUp

func _ready():
	$Area3D.body_entered.connect(_on_area_entered)

func apply_powerup(player: Node3D):
	if player is Player:
		player.show_power_up_bubble("speed_up", effect_duration)
