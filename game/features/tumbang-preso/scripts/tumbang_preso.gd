extends Node2D

enum TurnPhase { PLAYER_TURN, PLAYER_ESCAPE, ENEMY_TURN, ENEMY_ESCAPE }

@export var max_score: int = 5

var enemy_accuracy: int = 0
var enemy_speed: int = 0
var enemy_phase_two_accuracy: int = 0
var enemy_phase_two_speed: int = 0
var player_score: int = 0
var enemy_score: int = 0
var enemy_phase: int = 1
var setup_complete: bool = false
var current_phase: TurnPhase = TurnPhase.PLAYER_TURN

@onready var power_bar = $PowerBar
@onready var totoy = $Totoy
@onready var slipper: Area2D = $Slipper
@onready var can: Area2D = $Can

var slipper_start_position: Vector2 = Vector2.ZERO
var can_start_position: Vector2 = Vector2.ZERO

signal player_score_changed(score: int)
signal enemy_score_changed(score: int)
signal player_max_score_reached(score: int)
signal enemy_max_score_reached(score: int)
signal phase_changed(text: String)


func _ready() -> void:
	if not power_bar.power_bar_stopped.is_connected(_on_power_bar_stopped):
		power_bar.power_bar_stopped.connect(_on_power_bar_stopped)

	_record_slipper_and_can_positions()
	_set_slipper_visibility(false)
	_set_totoy_idle()

	if setup_complete:
		_apply_current_mode()
		power_bar.start()


func setup(accuracy: int, speed: int, second_accuracy: int, second_speed: int) -> void:
	enemy_accuracy = clampi(accuracy, 0, 100)
	enemy_speed = clampi(speed, 0, 100)
	enemy_phase_two_accuracy = clampi(second_accuracy, 0, 100)
	enemy_phase_two_speed = clampi(second_speed, 0, 100)
	player_score = 0
	enemy_score = 0
	enemy_phase = 1
	current_phase = TurnPhase.PLAYER_TURN
	setup_complete = true
	power_bar.set_restart_enabled(true)
	power_bar.reset()

	if is_node_ready():
		_record_slipper_and_can_positions()
		_set_slipper_visibility(false)
		_set_totoy_idle()
		_apply_current_mode()
		power_bar.start()


func _apply_current_mode() -> void:
	match current_phase:
		TurnPhase.PLAYER_TURN:
			_enter_player_turn()
		TurnPhase.PLAYER_ESCAPE:
			_enter_player_escape()
		TurnPhase.ENEMY_TURN:
			_enter_enemy_turn()
		TurnPhase.ENEMY_ESCAPE:
			_enter_enemy_escape()


func _enter_player_turn() -> void:
	current_phase = TurnPhase.PLAYER_TURN

	var accuracy = 100 - ((float(enemy_accuracy) + float(enemy_speed)) / 2.0)
	_apply_half_orange_zones(accuracy)

	var arrow_speed := ((float(enemy_accuracy) + float(enemy_speed)) / 15.0) * 100.0
	power_bar.set_arrow_speed(arrow_speed)
	phase_changed.emit("Player's Turn")


func _enter_player_escape() -> void:
	current_phase = TurnPhase.PLAYER_ESCAPE
	_apply_escape_mode(enemy_speed)
	phase_changed.emit("Player's Escape Mode")


func _apply_enemy_accuracy(accuracy: int) -> void:
	var clamped_accuracy := clampi(accuracy, 0, 100)
	var inverted_accuracy := 100 - clamped_accuracy

	_apply_half_orange_zones(inverted_accuracy)


func _apply_escape_mode(speed: int) -> void:
	var clamped_speed := clampi(speed, 0, 100)
	var inverted_speed := 100 - clamped_speed

	_apply_half_orange_zones(inverted_speed)


func _apply_half_orange_zones(value: int) -> void:
	var half_of_orange := (value / 2.0) / 2.0

	var green_zone_end := clampf((value - half_of_orange) / 100.0, 0.0, 1.0)
	var orange_zone_end := clampf((green_zone_end * 100.0 + (half_of_orange * 2.0)) / 100.0, green_zone_end, 1.0)

	if green_zone_end == 0:
		orange_zone_end = 0.1

	power_bar.set_zone_ranges(green_zone_end, orange_zone_end)


func _enter_enemy_turn() -> void:
	current_phase = TurnPhase.ENEMY_TURN
	_apply_enemy_accuracy(enemy_accuracy)
	phase_changed.emit("Enemy's Turn")


func _enter_enemy_escape() -> void:
	current_phase = TurnPhase.ENEMY_ESCAPE
	_apply_escape_mode(enemy_speed)
	phase_changed.emit("Enemy's Escape Mode")


func _set_totoy_idle() -> void:
	if totoy and totoy.has_method("play_idle_with_slipper"):
		totoy.play_idle_with_slipper()


func _on_power_bar_stopped(_position: float, zone: String) -> void:
	print("[TumbangPreso] _on_power_bar_stopped received -> position=", _position, " zone=", zone, " phase=", current_phase, " player_score=", player_score, " enemy_score=", enemy_score)
	match current_phase:
		TurnPhase.PLAYER_TURN:
			_play_totoy_throw()
			var scored := _did_score(zone)

			if scored:
				_fly_slipper_to_can()

				player_score += 1
				print("[TumbangPreso] player scored -> new player_score=", player_score)
				player_score_changed.emit(player_score)
				if player_score >= max_score:
					if enemy_phase == 1:
						_advance_enemy_phase()
						return
					power_bar.set_restart_enabled(false)
					player_max_score_reached.emit(player_score)
					return

			if scored:
				_enter_player_escape()
			else:
				_fly_slipper_to_can_side_then_enemy_turn()
		TurnPhase.PLAYER_ESCAPE:
			if _did_score(zone):
				_enter_player_turn()
			else:
				_enter_enemy_turn()
		TurnPhase.ENEMY_TURN:
			# _play_totoy_throw()
			var enemy_scored := _did_enemy_score(zone)
			if enemy_scored:
				enemy_score += 1
				enemy_score_changed.emit(enemy_score)
				if enemy_score >= max_score:
					power_bar.set_restart_enabled(false)
					enemy_max_score_reached.emit(enemy_score)
					return

			if enemy_scored:
				_enter_enemy_escape()
			else:
				_enter_player_turn()
		TurnPhase.ENEMY_ESCAPE:
			if _did_enemy_escape(zone):
				_enter_player_turn()
			else:
				_enter_enemy_turn()


func _advance_enemy_phase() -> void:
	enemy_phase = 2
	enemy_accuracy = enemy_phase_two_accuracy
	enemy_speed = enemy_phase_two_speed
	player_score = 0
	enemy_score = 0
	player_score_changed.emit(player_score)
	enemy_score_changed.emit(enemy_score)
	current_phase = TurnPhase.PLAYER_TURN
	_apply_current_mode()
	phase_changed.emit("Enemy's Second Phase")


func _did_score(zone: String) -> bool:
	if zone == "green":
		return true

	if zone == "orange":
		return _roll_half_chance()

	return false


func _did_enemy_score(zone: String) -> bool:
	if zone == "green":
		return false

	if zone == "red":
		return true

	if zone == "orange":
		return _roll_half_chance()

	return false


func _did_enemy_escape(zone: String) -> bool:
	return zone == "green" or (zone == "orange" and _roll_half_chance())


func _roll_half_chance() -> bool:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(0, 1) == 1


func _play_totoy_throw() -> void:
	if totoy and totoy.has_method("play_throw"):
		totoy.play_throw()


func _fly_slipper_to_can() -> void:
	if not (slipper and can):
		return

	await get_tree().create_timer(1.0).timeout
	_set_slipper_visibility(true)
	_reset_slipper_and_can_positions()

	var start: Vector2 = slipper.position
	var target: Vector2 = can.position
	var mid: Vector2 = (start + target) * 0.5 + Vector2(0, -180)

	var tween := get_tree().create_tween()
	tween.tween_property(slipper, "position", mid, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(slipper, "position", target, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_on_slipper_arrived"))


func _fly_slipper_to_can_side_then_enemy_turn() -> void:
	if not (slipper and can):
		_enter_enemy_turn()
		return

	await get_tree().create_timer(1.0).timeout
	_set_slipper_visibility(true)
	_reset_slipper_and_can_positions()

	var side_offset_direction: int = 1
	if slipper_start_position.x < can.position.x:
		side_offset_direction = -1

	var target: Vector2 = can.position + Vector2(90.0 * side_offset_direction, 0.0)
	var mid: Vector2 = (slipper.position + target) * 0.5 + Vector2(0, -180)

	var tween := get_tree().create_tween()
	tween.tween_property(slipper, "position", mid, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(slipper, "position", target, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished

	_set_slipper_visibility(false)
	_enter_enemy_turn()


func _on_slipper_arrived() -> void:
	print("[TumbangPreso] Slipper arrived at can")
	if can and can.has_method("on_slipper_hit"):
		can.call("on_slipper_hit")

	_move_can_to_hit_position()


func _record_slipper_and_can_positions() -> void:
	if slipper:
		slipper_start_position = slipper.position

	if can:
		can_start_position = can.position


func _reset_slipper_and_can_positions() -> void:
	if slipper:
		slipper.position = slipper_start_position

	if can:
		can.position = can_start_position


func _set_slipper_visibility(is_visible: bool) -> void:
	if slipper:
		slipper.visible = is_visible


func _move_can_to_hit_position() -> void:
	if not can:
		return

	var hit_offset := Vector2(0.0, -100.0)
	var tween := get_tree().create_tween()
	tween.tween_property(can, "position", can_start_position + hit_offset, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _restore_can_to_original_position() -> void:
	if not can:
		return

	var tween := get_tree().create_tween()
	tween.tween_property(can, "position", can_start_position, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
