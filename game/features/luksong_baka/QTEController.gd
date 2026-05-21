extends Node

const LETTERS = ["A", "S", "D", "F", "J", "K", "L"]

@onready var success_sfx = $SuccessSFX
@onready var fail_sfx = $FailSFX

# Assigned via Inspector
@export var qte_panel: Control
@export var hint_label: Label
@export var timer_bar: ColorRect

var sequence: Array[String] = []
var current_index: int = 0
var time_limit: float = 5.0
var time_elapsed: float = 0.0
var is_active: bool = false
var original_bar_width: float = 0.0

func _ready() -> void:
	qte_panel.visible = false
	original_bar_width = timer_bar.size.x

func _process(delta: float) -> void:
	if not is_active:
		return
	
	time_elapsed += delta
	var progress = 1.0 - (time_elapsed / time_limit)
	timer_bar.size.x = original_bar_width * clamp(progress, 0.0, 1.0)
	
	# Change color as time runs out
	if progress > 0.5:
		timer_bar.color = Color.GREEN
	elif progress > 0.25:
		timer_bar.color = Color.YELLOW
	else:
		timer_bar.color = Color.RED
	
	if time_elapsed >= time_limit:
		_on_fail()

func _input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventKey and event.pressed:
		var key = OS.get_keycode_string(event.keycode).to_upper()
		if key == sequence[current_index]:
			_on_correct_key()
		else:
			_on_fail()

func start_qte(seq_length: int, limit: float) -> void:
	sequence.clear()
	for i in seq_length:
		sequence.append(LETTERS[randi() % LETTERS.size()])
	current_index = 0
	time_limit = limit
	time_elapsed = 0.0
	is_active = true
	qte_panel.visible = true
	timer_bar.size.x = original_bar_width
	_show_current_letter()

func _show_current_letter() -> void:
	hint_label.text = sequence[current_index]

func _on_correct_key() -> void:
	current_index += 1
	if current_index >= sequence.size():
		_on_success()
	else:
		_show_current_letter()

func _on_success() -> void:
	is_active = false
	qte_panel.visible = false
	if success_sfx.stream:
		success_sfx.play()
	get_parent().on_qte_success()

func _on_fail() -> void:
	is_active = false
	qte_panel.visible = false
	if fail_sfx.stream:
		fail_sfx.play()
	get_parent().on_qte_fail()
