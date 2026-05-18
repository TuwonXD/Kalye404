extends Control

@onready var enemy_accuracy_input = $EnemyAccuracyInput
@onready var start_button = $StartButton

const TUMBANG_PRESO_SCENE := "res://tumbang_preso.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	enemy_accuracy_input.text_submitted.connect(_on_enemy_status_submitted)
	enemy_accuracy_input.text = "0"


func _on_enemy_status_submitted(_text: String) -> void:
	_on_start_button_pressed()


func _on_start_button_pressed() -> void:
	var packed_scene := load(TUMBANG_PRESO_SCENE) as PackedScene
	if packed_scene == null:
		return

	var next_scene = packed_scene.instantiate()
	next_scene.setup(_read_enemy_accuracy())

	get_tree().root.add_child(next_scene)
	get_tree().current_scene = next_scene

	queue_free()


func _read_enemy_accuracy() -> int:
	return clampi(int(enemy_accuracy_input.text), 0, 100)
