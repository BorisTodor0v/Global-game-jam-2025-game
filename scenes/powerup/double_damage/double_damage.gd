extends PowerUp

func _ready():
	$Area3D.body_entered.connect(_on_area_entered)

func apply_powerup(_player: Node3D):
	var projectile_script = load("res://scenes/projectile/projectile.gd")
	projectile_script.set_damage_multiplier(2.0, effect_duration)
