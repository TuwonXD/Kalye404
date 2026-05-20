extends Control

@onready var enemy_accuracy_input = $ModifiedEnemy/EnemyAccuracyInput
@onready var enemy_speed_input = $ModifiedEnemy/EnemySpeedInput
@onready var challenge_button = $ModifiedEnemy/ChallengeButton

@onready var bronze_stats_label = $BronzeBoss/Stats
@onready var silver_stats_label = $SilverBoss/Stats
@onready var gold_stats_label = $GoldBoss/Stats
@onready var bronze_grunt_a_stats = $BronzeGruntA/Stats
@onready var bronze_grunt_b_stats = $BronzeGruntB/Stats
@onready var silver_grunt_a_stats = $SilverGruntA/Stats
@onready var silver_grunt_b_stats = $SilverGruntB/Stats
@onready var gold_grunt_a_stats = $GoldGruntA/Stats
@onready var gold_grunt_b_stats = $GoldGruntB/Stats

const TUMBANG_PRESO_SCENE := "res://tumbang_preso.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	challenge_button.pressed.connect(_on_challenge_button_pressed)
	enemy_accuracy_input.text_submitted.connect(_on_challenge_button_pressed)
	enemy_speed_input.text_submitted.connect(_on_challenge_button_pressed)
	
	enemy_accuracy_input.text = "0"
	enemy_speed_input.text = "0"


func _on_challenge_button_pressed() -> void:
	_start_with_stats(_read_enemy_accuracy(), _read_enemy_speed())


func _start_with_stats(accuracy: int, speed: int) -> void:
	var packed_scene := load(TUMBANG_PRESO_SCENE) as PackedScene
	if packed_scene == null:
		return

	var next_scene = packed_scene.instantiate()

	get_tree().root.add_child(next_scene)
	get_tree().current_scene = next_scene

	next_scene.setup(clampi(accuracy, 0, 100), clampi(speed, 0, 100))

	queue_free()


func _read_enemy_accuracy() -> int:
	return clampi(int(enemy_accuracy_input.text), 0, 100)


func _read_enemy_speed() -> int:
	return clampi(int(enemy_speed_input.text), 0, 100)


func _parse_stats_from_label(label_node: Label) -> Array:
	var text := str(label_node.text)
	# Robustly extract integer sequences from the label text (works on Godot's String API)
	var nums: Array = []
	var cur := ""
	for ch in text:
		if ch >= "0" and ch <= "9":
			cur += ch
		else:
			if cur != "":
				nums.append(int(cur))
				cur = ""

	if cur != "":
		nums.append(int(cur))

	if nums.size() >= 2:
		return [clampi(nums[0], 0, 100), clampi(nums[1], 0, 100)]

	return [50, 50]




func _on_challenge_bronzeBoss_button_pressed() -> void:
	var stats = _parse_stats_from_label(bronze_stats_label)
	_start_with_stats(stats[0], stats[1])


func _on_challenge_silverBoss_button_pressed() -> void:
	var stats = _parse_stats_from_label(silver_stats_label)
	_start_with_stats(stats[0], stats[1])


func _on_challenge_goldBoss_button_pressed() -> void:
	var stats = _parse_stats_from_label(gold_stats_label)
	_start_with_stats(stats[0], stats[1])



func _on_challenge_bronzeGruntA_button_pressed() -> void:
	var stats = _parse_stats_from_label(bronze_grunt_a_stats)
	_start_with_stats(stats[0], stats[1])


func _on_challenge_bronzeGruntB_button_pressed() -> void:
	var stats = _parse_stats_from_label(bronze_grunt_b_stats)
	_start_with_stats(stats[0], stats[1])


func _on_challenge_silverGruntA_button_pressed() -> void:
	var stats = _parse_stats_from_label(silver_grunt_a_stats)
	_start_with_stats(stats[0], stats[1])


func _on_challenge_silverGruntB_button_pressed() -> void:
	var stats = _parse_stats_from_label(silver_grunt_b_stats)
	_start_with_stats(stats[0], stats[1])


func _on_challenge_goldGruntA_button_pressed() -> void:
	var stats = _parse_stats_from_label(gold_grunt_a_stats)
	_start_with_stats(stats[0], stats[1])


func _on_challenge_goldGruntB_button_pressed() -> void:
	var stats = _parse_stats_from_label(gold_grunt_b_stats)
	_start_with_stats(stats[0], stats[1])