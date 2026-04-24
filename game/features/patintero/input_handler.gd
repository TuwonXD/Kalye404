class_name InputHandler
extends Node
## Manages the Execution Phase of a Patintero duel.
## Listens for directional input, validates against the expected sequence,
## and manages the execution countdown timer.
##
## Attach to: InputHandler (Node, direct child of PatinteroGame)

## Emitted for every directional key the player presses.
## Used by the state machine to update the InputFeedback UI.
signal key_pressed(direction: String, was_correct: bool)

## Emitted when the player enters the full sequence correctly.
signal sequence_completed

## Emitted when the player presses a wrong key.
## [param wrong_direction]: The incorrect direction that was pressed.
signal input_failed(wrong_direction: String)

## Emitted when the countdown timer reaches zero.
signal time_expired

# ── Internal State ──────────────────────────────────────────────────────────

var _expected_sequence: Array[String] = []
var _input_index: int = 0
var _time_remaining: float = 0.0
var _total_time: float = 0.0
var _active: bool = false

# ── Public API ───────────────────────────────────────────────────────────────

func _ready() -> void:
	# Timer only runs during the execution phase.
	set_process(false)

## Begins the execution phase.
## [param expected_sequence]: The correct sequence the player must reproduce.
## [param time_limit]: Total seconds allowed to complete the sequence.
func start(expected_sequence: Array[String], time_limit: float) -> void:
	_expected_sequence = expected_sequence
	_input_index = 0
	_time_remaining = time_limit
	_total_time = time_limit
	_active = true
	set_process(true)

## Stops listening for input and halts the timer. Call this when leaving execution phase.
func stop() -> void:
	_active = false
	set_process(false)

## Returns the timer's remaining fraction (1.0 = full, 0.0 = empty).
## Poll this each frame from the state machine to update the TimerBar.
func get_time_fraction() -> float:
	if _total_time <= 0.0:
		return 0.0
	return clampf(_time_remaining / _total_time, 0.0, 1.0)

# ── Internal Logic ────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if not _active:
		return
	_time_remaining -= delta
	if _time_remaining <= 0.0:
		stop()
		time_expired.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return

	var direction := _get_direction_from_event(event)
	if direction.is_empty():
		return  # Not a directional key — ignore.

	# Consume the event so UI elements don't also react.
	get_viewport().set_input_as_handled()

	var expected := _expected_sequence[_input_index]
	var was_correct: bool = direction == expected

	key_pressed.emit(direction, was_correct)

	if was_correct:
		_input_index += 1
		if _input_index >= _expected_sequence.size():
			# All keys entered correctly in order.
			stop()
			sequence_completed.emit()
	else:
		# Wrong key — fail immediately.
		stop()
		input_failed.emit(direction)

## Maps input actions to direction strings.
## Accepts both arrow keys and WASD because both are mapped to the same actions.
func _get_direction_from_event(event: InputEvent) -> String:
	if event.is_action_pressed("move_up"):
		return "up"
	elif event.is_action_pressed("move_down"):
		return "down"
	elif event.is_action_pressed("move_left"):
		return "left"
	elif event.is_action_pressed("move_right"):
		return "right"
	return ""
