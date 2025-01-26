extends Control

@export var hud: HUD


func _ready():
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	hud.visible = true
	hud.crosshair.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	hud.visible = false
	hud.crosshair.visible = false
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()

func _process(_delta):
	testEsc()
