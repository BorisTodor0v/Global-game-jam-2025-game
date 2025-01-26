class_name HUD
extends Control

@export var score_label: Label
@export var combo_multiplier: Label
@export var points_gain_label: Label
@export var combo_progress: ProgressBar
@export var crosshair: TextureRect

var current_score := 0.0
var display_score := 0.0

var points_gain_tween: Tween
var score_tween: Tween

func _ready():
	combo_progress.visible = false
	combo_multiplier.visible = false

func update_score(score: float):
	var old_score = current_score
	current_score = score

	_kill_tween(score_tween)

	score_tween = create_tween()
	# Change and animate score
	score_tween.tween_method(
		_update_score_display,
		old_score,
		current_score,
		0.5
	).set_trans(Tween.TRANS_CUBIC)
	

func update_combo(combo: int, multiplier: float):
	if combo_multiplier:
		combo_multiplier.text = "%.1fx" % multiplier
		combo_progress.visible = combo != 0
		combo_multiplier.visible = combo != 0

func update_timer(time_left: float, max_time: float):
	if combo_progress:
		combo_progress.value = (time_left / max_time) * 100

func show_points_gained(points: float):
	_kill_tween(points_gain_tween)
	
	points_gain_label.text = "+%d" % points
	points_gain_label.modulate.a = 0

	points_gain_tween = create_tween()
	points_gain_tween.set_parallel(true)

	# Fade in
	points_gain_tween.tween_property(points_gain_label, "modulate:a", 1.0, 0.3)
	# Fade out
	points_gain_tween.tween_property(points_gain_label, "modulate:a", 0.0, 0.3) \
		.set_delay(0.5)

func _kill_tween(tween: Tween):
	if tween and tween.is_valid():
		tween.kill()

func _update_score_display(value: float):
	if score_label:
		score_label.text = "Score: %d"%value
