extends Control

@onready var bronze_challenge_button = $Bronze/ChallengeButton
@onready var silver_challenge_button = $Silver/ChallengeButton
@onready var gold_challenge_button = $Gold/ChallengeButton

@onready var enemy_accuracy_input = $ModifiedEnemy/EnemyAccuracyInput
@onready var enemy_speed_input = $ModifiedEnemy/EnemySpeedInput
@onready var custom_challenge_button = $ModifiedEnemy/ChallengeButton

const TUMBANG_PRESO_SCENE := "res://features/tumbang-preso/scenes/game.tscn"

func _ready() -> void:
	bronze_challenge_button.pressed.connect(_on_bronze_challenge_pressed)
	silver_challenge_button.pressed.connect(_on_silver_challenge_pressed)
	gold_challenge_button.pressed.connect(_on_gold_challenge_pressed)
	custom_challenge_button.pressed.connect(_on_custom_challenge_pressed)
	enemy_accuracy_input.text_submitted.connect(_on_custom_challenge_submitted)
	enemy_speed_input.text_submitted.connect(_on_custom_challenge_submitted)
	
	enemy_accuracy_input.text = "0"
	enemy_speed_input.text = "0"


func _on_bronze_challenge_pressed() -> void:
	_start_with_stats(50, 50, 60, 60)


func _on_silver_challenge_pressed() -> void:
	_start_with_stats(80, 80, 90, 75)


func _on_gold_challenge_pressed() -> void:
	_start_with_stats(95, 90, 100, 100)


func _on_custom_challenge_pressed() -> void:
	var accuracy := _read_enemy_accuracy()
	var speed := _read_enemy_speed()
	_start_with_stats(accuracy, speed, accuracy, speed)


func _on_custom_challenge_submitted(_text: String) -> void:
	_on_custom_challenge_pressed()


func _start_with_stats(accuracy: int, speed: int, second_accuracy: int, second_speed: int) -> void:
	var packed_scene := load(TUMBANG_PRESO_SCENE) as PackedScene
	if packed_scene == null:
		return

	var next_scene = packed_scene.instantiate()

	get_tree().root.add_child(next_scene)
	get_tree().current_scene = next_scene

	next_scene.setup(clampi(accuracy, 0, 100), clampi(speed, 0, 100), clampi(second_accuracy, 0, 100), clampi(second_speed, 0, 100))

	queue_free()


func _read_enemy_accuracy() -> int:
	return clampi(int(enemy_accuracy_input.text), 0, 100)


func _read_enemy_speed() -> int:
	return clampi(int(enemy_speed_input.text), 0, 100)
