extends Node3D


func _on_start_game_button_pressed():
	$Control/HBoxContainer/Control2/MarginContainer/VBoxContainer.hide()
	$Control/HBoxContainer/Control3/MarginContainer/VBoxContainer/CreditsLabel.hide()
	$Control/HBoxContainer/Control3/MarginContainer/VBoxContainer/LoadingLabel.show()
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_quit_game_button_pressed():
	get_tree().quit()
