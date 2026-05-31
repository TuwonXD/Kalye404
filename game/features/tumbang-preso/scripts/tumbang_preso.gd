extends Node2D

enum TurnPhase { PLAYER_TURN, PLAYER_ESCAPE, ENEMY_TURN, ENEMY_ESCAPE }

@export var max_score: int = 5

var enemy_accuracy: int = 0
var enemy_speed: int = 0
var enemy_phase_two_accuracy: int = 0
var enemy_phase_two_speed: int = 0

var player_score: int = 0
var enemy_score: int = 0

var setup_complete: bool = false
var enemy_phase: int = 1

var prev_phase: TurnPhase = TurnPhase.PLAYER_TURN
var current_phase: TurnPhase = TurnPhase.PLAYER_TURN

var pending_player_escape_sequence: int = false
var pending_player_turn_after_escape_return: int = false
var player_escape_timeout_token: int = 0

var pending_enemy_escape_sequence: bool = false
var pending_enemy_turn_after_escape_return: bool = false
var enemy_escape_timeout_token: int = 0

var player_escape_sequence_token: int = 0
var enemy_escape_sequence_token: int = 0

var totoy_is_taya: bool = false

@onready var power_bar = $PowerBar
@onready var totoy = $Totoy
@onready var enemy_slot: Node2D = $Enemy
@onready var slipper: Area2D = $Slipper
@onready var can: Area2D = $Can

var thrower_position: Vector2 = Vector2.ZERO
var taya_position: Vector2 = Vector2.ZERO
var slipper_start_position: Vector2 = Vector2.ZERO
var can_start_position: Vector2 = Vector2.ZERO

var enemy_scene_path: String = ""
var enemy_instance: Node = null

signal player_score_changed(score: int)
signal enemy_score_changed(score: int)
signal player_max_score_reached(score: int)
signal enemy_max_score_reached(score: int)
signal phase_changed(text: String)


func _ready() -> void:
	if not power_bar.power_bar_stopped.is_connected(_on_power_bar_stopped):
		power_bar.power_bar_stopped.connect(_on_power_bar_stopped)

	_spawn_selected_enemy()
	_record_starting_positions()
	_set_slipper_visibility(false)
	_set_totoy_idle_with_slipper()

	if setup_complete:
		_apply_current_mode()
		power_bar.start()

func setup(accuracy: int, speed: int, second_accuracy: int, second_speed: int, selected_enemy_scene_path: String = "") -> void:
	enemy_accuracy = clampi(accuracy, 0, 100)
	enemy_speed = clampi(speed, 0, 100)

	enemy_phase_two_accuracy = clampi(second_accuracy, 0, 100)
	enemy_phase_two_speed = clampi(second_speed, 0, 100)
	
	enemy_scene_path = selected_enemy_scene_path

	player_score = 0
	enemy_score = 0

	enemy_phase = 1
	current_phase = TurnPhase.PLAYER_TURN

	setup_complete = true
	power_bar.set_restart_enabled(true)
	power_bar.reset()

	if is_node_ready():
		_spawn_selected_enemy()
		_record_starting_positions()
		_set_slipper_visibility(false)
		_set_totoy_idle_with_slipper()
		_apply_current_mode()
		power_bar.start()


func _enter_player_turn() -> void:
	current_phase = TurnPhase.PLAYER_TURN

	_clear_player_escape_state()
	_clear_enemy_escape_state()

	power_bar.set_restart_enabled(true)
	
	_set_enemy_idle_down()
	_set_totoy_idle_with_slipper()

	var accuracy = 100 - ((float(enemy_accuracy) + float(enemy_speed)) / 2.0)

	_apply_half_orange_zones(accuracy)

	var arrow_speed := ((float(enemy_accuracy) + float(enemy_speed)) / 15.0) * 100.0

	power_bar.set_arrow_speed(arrow_speed)
	phase_changed.emit("Player's Turn")

func _enter_enemy_turn() -> void:
	current_phase = TurnPhase.ENEMY_TURN

	_clear_player_escape_state()
	_clear_enemy_escape_state()

	power_bar.set_restart_enabled(true)
	
	_set_totoy_idle_down()
	_set_enemy_idle_with_slipper()

	_apply_enemy_accuracy(enemy_accuracy)
	phase_changed.emit("Enemy's Turn")

func _enter_player_escape() -> void:
	current_phase = TurnPhase.PLAYER_ESCAPE
	power_bar.set_restart_enabled(true)
	_apply_escape_mode(enemy_speed)
	phase_changed.emit("Player's Escape Mode")

func _enter_enemy_escape() -> void:
	current_phase = TurnPhase.ENEMY_ESCAPE

	# _clear_player_escape_state()
	# pending_player_turn_after_escape_return = false

	power_bar.set_restart_enabled(true)
	_apply_escape_mode(enemy_speed)
	phase_changed.emit("Enemy's Escape Mode")

func _apply_half_orange_zones(value: int) -> void:
	var half_of_orange := (value / 2.0) / 2.0

	var green_zone_end := clampf((value - half_of_orange) / 100.0, 0.0, 1.0)
	var orange_zone_end := clampf((green_zone_end * 100.0 + (half_of_orange * 2.0)) / 100.0, green_zone_end, 1.0)

	if green_zone_end == 0:
		orange_zone_end = 0.1

	power_bar.set_zone_ranges(green_zone_end, orange_zone_end)

func _apply_enemy_accuracy(accuracy: int) -> void:
	var clamped_accuracy := clampi(accuracy, 0, 100)
	var inverted_accuracy := 100 - clamped_accuracy

	_apply_half_orange_zones(inverted_accuracy)

func _apply_escape_mode(speed: int) -> void:
	var clamped_speed := clampi(speed, 0, 100)
	var inverted_speed := 100 - clamped_speed

	_apply_half_orange_zones(inverted_speed)

func _roll_half_chance() -> bool:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(0, 1) == 1




func _on_power_bar_stopped(_position: float, zone: String) -> void:
	print("[TumbangPreso] _on_power_bar_stopped received -> position=", _position, " zone=", zone, " phase=", current_phase, " player_score=", player_score, " enemy_score=", enemy_score)

	match current_phase:
		TurnPhase.PLAYER_TURN:
			_play_totoy_throw()

			if _did_win(zone):
				pending_player_escape_sequence = true
				power_bar.set_restart_enabled(false)
				_fly_slipper_to_can()

				player_score += 1
				print("[TumbangPreso] Totoy scored -> current_score=", player_score)
				player_score_changed.emit(player_score)

				if player_score >= max_score:
					pending_player_escape_sequence = false
					_cancel_player_escape_timeout()
					if enemy_phase == 1:
						_advance_enemy_phase()
						return
					power_bar.set_restart_enabled(false)
					player_max_score_reached.emit(player_score)
					return
				# bar stays off — _begin_player_escape_mode() owns restarting it

			else:
				power_bar.set_restart_enabled(false)
				await _fly_slipper_to_miss_can()
				await _totoy_taya()
				_enter_enemy_turn()
				power_bar.start()

		TurnPhase.PLAYER_ESCAPE:
			if _did_win(zone):
				pending_player_turn_after_escape_return = true
				power_bar.set_restart_enabled(false)
			else:
				power_bar.set_restart_enabled(false)

				player_escape_sequence_token += 1

				totoy.global_position = taya_position if totoy_is_taya else thrower_position

				enemy_instance.global_position = thrower_position if totoy_is_taya else taya_position
				
				_set_slipper_visibility(false)
				slipper.global_position = slipper_start_position
				can.global_position = can_start_position

				await _totoy_taya()
				_enter_enemy_turn()
				power_bar.start()
			
			
			await get_tree().create_timer(2.5).timeout
			can.global_position = can_start_position

		TurnPhase.ENEMY_TURN:
			_play_enemy_throw()

			if _did_lose(zone):
				pending_enemy_escape_sequence = true
				power_bar.set_restart_enabled(false)
				_fly_slipper_to_can()

				enemy_score += 1
				print("[TumbangPreso] Enemy scored -> current_score=", enemy_score)
				enemy_score_changed.emit(enemy_score)

				if enemy_score >= max_score:
					pending_enemy_escape_sequence = false
					_cancel_enemy_escape_timeout()
					power_bar.set_restart_enabled(false)
					enemy_max_score_reached.emit(enemy_score)
					return
				# bar stays off — _begin_enemy_escape_mode() owns restarting it

			else:
				power_bar.set_restart_enabled(false)
				await _fly_slipper_to_miss_can()
				await _enemy_taya()
				_enter_player_turn()
				power_bar.start()

		TurnPhase.ENEMY_ESCAPE:
			if _did_win(zone):
				power_bar.set_restart_enabled(false)

				# Cancel the running escape sequence
				enemy_escape_sequence_token += 1

				# Snap characters to known positions before swapping
				# so the taya starts clean regardless of where the sequence left them
				totoy.global_position = taya_position if totoy_is_taya else thrower_position
				enemy_instance.global_position = thrower_position if totoy_is_taya else taya_position

				_set_slipper_visibility(false)
				slipper.global_position = slipper_start_position
				can.global_position = can_start_position

				await _enemy_taya()
				_enter_player_turn()
				power_bar.start()

			else:
				pending_enemy_turn_after_escape_return = true
				power_bar.set_restart_enabled(false)
			
			
			await get_tree().create_timer(2.5).timeout
			can.global_position = can_start_position

func _did_win(zone: String) -> bool:
	return zone == "green" or (zone == "orange" and _roll_half_chance())

func _did_lose(zone: String) -> bool:
	if zone == "green":
		return false

	if zone == "orange":
		return _roll_half_chance()

	return true




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

func _spawn_selected_enemy() -> void:
	if enemy_slot == null:
		return

	if enemy_instance and is_instance_valid(enemy_instance):
		enemy_instance.queue_free()
		enemy_instance = null

	var resolved_scene_path := enemy_scene_path
	if resolved_scene_path == "":
		resolved_scene_path = "res://features/tumbang-preso/scenes/bronze.tscn"

	var packed_scene := load(resolved_scene_path) as PackedScene
	if packed_scene == null:
		return

	enemy_instance = packed_scene.instantiate()
	enemy_slot.add_child(enemy_instance)
	_set_enemy_idle_for_current_phase()

func _advance_enemy_phase() -> void:
	enemy_phase = 2

	enemy_accuracy = enemy_phase_two_accuracy
	enemy_speed = enemy_phase_two_speed

	player_score = 0
	enemy_score = 0

	_clear_player_escape_state()

	player_score_changed.emit(player_score)
	enemy_score_changed.emit(enemy_score)

	current_phase = TurnPhase.PLAYER_TURN
	_apply_current_mode()
	phase_changed.emit("Enemy's Second Phase")

func _set_enemy_idle_for_current_phase() -> void:
	if current_phase == TurnPhase.PLAYER_TURN:
		_set_enemy_idle_down()
	else:
		_set_enemy_idle_with_slipper()

func _set_totoy_idle_down() -> void:
	if totoy and totoy.has_method("play_idle_down"):
		totoy.call("play_idle_down")

func _set_enemy_idle_down() -> void:
	if enemy_instance and enemy_instance.has_method("play_idle_down"):
		enemy_instance.call("play_idle_down")

func _set_totoy_idle_with_slipper() -> void:
	if totoy and totoy.has_method("play_idle_with_slipper"):
		totoy.play_idle_with_slipper()

func _set_enemy_idle_with_slipper() -> void:
	if enemy_instance and enemy_instance.has_method("play_idle_with_slipper"):
		enemy_instance.call("play_idle_with_slipper")

func _play_totoy_throw() -> void:
	if totoy and totoy.has_method("play_throw"):
		totoy.play_throw()

func _play_enemy_throw() -> void:
	if enemy_instance and enemy_instance.has_method("play_throw"):
		enemy_instance.play_throw()

func _play_totoy_pickup() -> void:
	if totoy and totoy.has_method("play_pickup"):
		totoy.play_pickup()

func _play_enemy_pickup() -> void:
	if enemy_instance and enemy_instance.has_method("play_pickup"):
		enemy_instance.play_pickup()


func _record_starting_positions() -> void:
	if totoy:
		thrower_position = totoy.global_position
	if enemy_instance:
		taya_position = enemy_instance.global_position
	if slipper:
		slipper_start_position = slipper.global_position
	if can:
		can_start_position = can.global_position

func _set_slipper_visibility(is_visible: bool) -> void:
	if slipper:
		slipper.visible = is_visible

func _clear_player_escape_state() -> void:
	pending_player_escape_sequence = false
	pending_player_turn_after_escape_return = false
	_cancel_player_escape_timeout()

func _clear_enemy_escape_state() -> void:
	pending_enemy_escape_sequence = false
	pending_enemy_turn_after_escape_return = false
	_cancel_enemy_escape_timeout()

func _cancel_player_escape_timeout() -> void:
	player_escape_timeout_token += 1

func _cancel_enemy_escape_timeout() -> void:
	enemy_escape_timeout_token += 1

func _fly_slipper_to_can() -> void:
	if not (slipper and can):
		return

	await get_tree().create_timer(1.0).timeout
	_set_slipper_visibility(true)

	# _reset_slipper_and_can_positions()

	var target: Vector2 = can.position

	var tween := _create_slipper_flight_tween(target, 110.0, 0.8)
	tween.tween_callback(Callable(self, "_on_slipper_arrived"))

func _create_slipper_flight_tween(target_position: Vector2, arc_height: float, duration: float) -> Tween:
	var start_position: Vector2 = slipper.position
	var tween := get_tree().create_tween()

	tween.tween_method(func(progress: float) -> void:
		var eased_progress := progress * progress * (3.0 - 2.0 * progress)
		var base_position := start_position.lerp(target_position, eased_progress)
		var arc_offset := sin(eased_progress * PI) * arc_height
		slipper.position = base_position + Vector2(0.0, -arc_offset)
	, 0.0, 1.0, duration)
	return tween

func _on_slipper_arrived() -> void:
	print("[TumbangPreso] Slipper arrived at can")
	if not pending_player_escape_sequence and not pending_enemy_escape_sequence:
		return

	_move_can_to_hit_position()

	if current_phase == TurnPhase.PLAYER_TURN:
		_begin_player_escape_mode()
		_run_player_escape_sequence()
	else:
		_begin_enemy_escape_mode()
		_run_enemy_escape_sequence()

func _move_can_to_hit_position() -> void:
	if not can:
		return

	var hit_offset := Vector2(0.0, -100.0)
	var tween := get_tree().create_tween()

	tween.tween_property(can, "position", can_start_position + hit_offset, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _begin_player_escape_mode() -> void:
	_enter_player_escape()
	power_bar.start()
	_start_player_escape_timeout()

func _begin_enemy_escape_mode() -> void:
	_enter_enemy_escape()
	power_bar.start()
	_start_enemy_escape_timeout()

func _start_player_escape_timeout() -> void:
	player_escape_timeout_token += 1
	var timeout_token := player_escape_timeout_token
	await get_tree().create_timer(5.0).timeout
	if timeout_token != player_escape_timeout_token:
		return

	if current_phase != TurnPhase.PLAYER_ESCAPE:
		return

	power_bar.force_stop("red")

func _start_enemy_escape_timeout() -> void:
	enemy_escape_timeout_token += 1
	var timeout_token := enemy_escape_timeout_token
	await get_tree().create_timer(5.0).timeout

	if timeout_token != enemy_escape_timeout_token:
		return

	if current_phase != TurnPhase.ENEMY_ESCAPE:
		return

	power_bar.force_stop("red")

func _run_player_escape_sequence() -> void:
	if totoy == null or not totoy.has_method("move_to_position"):
		return

	player_escape_sequence_token += 1
	var my_token := player_escape_sequence_token

	var slipper_target := slipper.global_position

	await totoy.move_to_position(slipper_target, 2.0, "run-up", 2)
	if my_token != player_escape_sequence_token:
		return  # sequence was cancelled, taya swap took over

	totoy.play_pickup()
	_set_slipper_visibility(false)

	await get_tree().create_timer(1.0).timeout
	if my_token != player_escape_sequence_token:
		return

	await totoy.move_to_position(thrower_position, 2.0, "run-down", 2)
	if my_token != player_escape_sequence_token:
		return

	slipper.global_position = slipper_start_position
	_set_totoy_idle_with_slipper()

	if pending_player_turn_after_escape_return:
		pending_player_turn_after_escape_return = false
		_enter_player_turn()
		power_bar.start()
	elif current_phase == TurnPhase.PLAYER_ESCAPE:
		_enter_enemy_turn()
		power_bar.start()

func _run_enemy_escape_sequence() -> void:
	if enemy_instance == null or not enemy_instance.has_method("move_to_position"):
		return

	enemy_escape_sequence_token += 1
	var my_token := enemy_escape_sequence_token

	var slipper_target: Vector2 = enemy_instance.get_parent().to_local(slipper.global_position)

	await enemy_instance.move_to_position(slipper_target, 2.0, "run-up", 2)
	if my_token != enemy_escape_sequence_token:
		return

	enemy_instance.play_pickup()
	_set_slipper_visibility(false)

	await get_tree().create_timer(1.0).timeout
	if my_token != enemy_escape_sequence_token:
		return

	var local_return: Vector2 = enemy_instance.get_parent().to_local(thrower_position)
	await enemy_instance.move_to_position(local_return, 2.0, "run-down", 2)
	if my_token != enemy_escape_sequence_token:
		return

	slipper.global_position = slipper_start_position
	_set_enemy_idle_with_slipper()

	if pending_enemy_turn_after_escape_return and current_phase == TurnPhase.ENEMY_ESCAPE:
		pending_enemy_turn_after_escape_return = false
		_enter_enemy_turn()
		power_bar.start()

	elif current_phase == TurnPhase.ENEMY_ESCAPE:
		_enter_player_turn()
		power_bar.start()

func _fly_slipper_to_miss_can() -> void:
	if not (slipper and can):
		_enter_enemy_turn()
		return

	await get_tree().create_timer(1.0).timeout
	_set_slipper_visibility(true)

	var side_offset_direction: int = 1
	if slipper_start_position.x < can.position.x:
		side_offset_direction = -1

	var map_width := get_viewport_rect().size.x
	if map_width <= 0.0:
		map_width = 1152.0

	var safe_margin := 64.0
	var avoid_radius := 32.0
	var target_x := 0.0
	var target := Vector2.ZERO
	var tries := 0
	while true:
		target_x = clampf(randf_range(safe_margin, map_width - safe_margin), safe_margin, map_width - safe_margin)
		if side_offset_direction < 0 and target_x > can.position.x:
			target_x = clampf(can.position.x - randf_range(64.0, 180.0), safe_margin, map_width - safe_margin)
		elif side_offset_direction > 0 and target_x < can.position.x:
			target_x = clampf(can.position.x + randf_range(64.0, 180.0), safe_margin, map_width - safe_margin)

		target = Vector2(target_x, can.position.y)
		if target.distance_to(can_start_position) > avoid_radius:
			break

		tries += 1
		if tries >= 6:
			var fallback_offset := avoid_radius + 64.0
			if target_x <= can_start_position.x:
				target_x = clampf(can_start_position.x - fallback_offset, safe_margin, map_width - safe_margin)
			else:
				target_x = clampf(can_start_position.x + fallback_offset, safe_margin, map_width - safe_margin)
			target = Vector2(target_x, can.position.y)
			if target.distance_to(can_start_position) > avoid_radius:
				break
	var tween := _create_slipper_flight_tween(target, 90.0, 0.8)
	await tween.finished
	await get_tree().create_timer(0.5).timeout

	_set_slipper_visibility(false)
	slipper.global_position = slipper_start_position

func _totoy_taya() -> void:
	if totoy == null or enemy_instance == null:
		return

	totoy_is_taya = true

	totoy.play_animation_loops("run-up", 2)
	enemy_instance.play_animation_loops("run-down", 2)

	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(totoy, "global_position", taya_position, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(enemy_instance, "global_position", thrower_position, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	await get_tree().create_timer(2.0).timeout
	_set_totoy_idle_down()
	_set_enemy_idle_with_slipper()

func _enemy_taya() -> void:
	if totoy == null or enemy_instance == null:
		return

	totoy_is_taya = false

	totoy.play_animation_loops("run-down", 2)
	enemy_instance.play_animation_loops("run-up", 2)

	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(totoy, "global_position", thrower_position, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(enemy_instance, "global_position", taya_position, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	await get_tree().create_timer(2.0).timeout
	_set_totoy_idle_with_slipper()
	_set_enemy_idle_down()
