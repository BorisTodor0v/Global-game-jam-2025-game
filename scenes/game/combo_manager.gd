class_name ComboManager
extends Node

signal combo_updated(combo: int, multiplier: float)
signal combo_timer_updated(time_left: float)
signal combo_ended

const BASE_COMBO_TIME := 5.0
const MIN_COMBO_TIME := 2.0
const TIME_DECREASE_PER_COMBO := 0.2
const MULTIPLIER_INCREMENT := 0.1

var current_combo := 0
var combo_timer := 0.0
var combo_active := false
var current_combo_time := BASE_COMBO_TIME

func _process(delta):
	if not combo_active: return

	combo_timer -= delta
	combo_timer_updated.emit(combo_timer, current_combo_time)

	if combo_timer <= 0:
		end_combo()

func end_combo():
	combo_active = false
	current_combo = 0
	combo_ended.emit()
	combo_updated.emit(current_combo, calculate_multiplier())

func on_enemy_killed():
	current_combo += 1
	current_combo_time = _calculate_combo_time()
	combo_timer = current_combo_time
	combo_active = true
	combo_updated.emit(current_combo, calculate_multiplier())

func _calculate_combo_time():
	var time = BASE_COMBO_TIME - (current_combo * TIME_DECREASE_PER_COMBO)
	return maxf(time, MIN_COMBO_TIME)

func calculate_multiplier():
	return 1.0 + (current_combo * MULTIPLIER_INCREMENT)
