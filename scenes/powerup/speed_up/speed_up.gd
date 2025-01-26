extends PowerUp

func _ready():
	$Area3D.body_entered.connect(_on_area_entered)

func apply_powerup(player: Node3D):
	if player.has_method("set_speed_multiplier"):
		player.set_speed_multiplier(2.0)
		await get_tree().create_timer(effect_duration).timeout
		player.set_speed_multiplier(1.0)
