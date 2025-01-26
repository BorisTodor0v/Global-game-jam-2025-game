class_name HUD
extends Control

@export var score_label: Label
@export var combo_label: Label
@export var timer_label: Label

func update_score(score: float):
	if score_label:
		score_label.text = "Score: %d" % score

func update_combo(combo: int, multiplier: float):
	if combo_label:
		combo_label.text = "Combo: x%d (%.1fx)" % [combo, multiplier]

func update_timer(time_left: float):
	if timer_label:
		timer_label.text = "Combo Time: %.2f" % time_left
