extends Node2D

# Difficulty resources
@export var difficulties: Array[LuksongBakaDifficulty] = []

var tutorial_intro_done: bool = false
var tutorial_first_fail_done: bool = false
var tutorial_first_success_done: bool = false

# Child node references
@onready var player = $Player
@onready var baka = $Baka
@onready var hud = $HUD
@onready var qte_controller = $QTEController

# Game state
var current_tier: int = 0
var current_level: int = 0
var lives: int = 3

func _ready() -> void:
	current_tier = 0
	lives = 3
	current_level = 0
	if current_tier == 0:
		await _play_dialogue("res://features/luksong_baka/dialogues/tutorial_intro.dtl")
	_start_level()

func _play_dialogue(timeline: String) -> void:
	Dialogic.start(timeline)
	await Dialogic.timeline_ended

func _start_level() -> void:
	var difficulty = difficulties[current_tier]
	hud.update_display(lives, difficulty.tier_name, current_level + 1)
	player.start_running()

func on_player_reached_baka() -> void:
	var difficulty = difficulties[current_tier]
	var time_limit = difficulty.time_per_level[current_level]
	var seq_length = difficulty.sequence_length
	if current_tier == 0 and not tutorial_intro_done:
		hud.show_message("Press the letter shown before time runs out!", 3.0)
		tutorial_intro_done = true
		await get_tree().create_timer(3.0).timeout
	qte_controller.start_qte(seq_length, time_limit)

func on_qte_success() -> void:
	player.do_jump()
	baka.rise_to_level(current_level)
	if current_tier == 0 and not tutorial_first_success_done:
		tutorial_first_success_done = true
		await get_tree().create_timer(1.5).timeout
		await _play_dialogue("res://features/luksong_baka/dialogues/tutorial_success.dtl")
	else:
		await get_tree().create_timer(1.5).timeout
	_advance_level()

func on_qte_fail() -> void:
	lives -= 1
	hud.update_display(lives, difficulties[current_tier].tier_name, current_level + 1)
	player.do_trip()
	if current_tier == 0 and not tutorial_first_fail_done:
		tutorial_first_fail_done = true
		await _play_dialogue("res://features/luksong_baka/dialogues/tutorial_fail.dtl")
	await get_tree().create_timer(0.6).timeout
	if lives <= 0:
		_game_over()
	else:
		player.reset_position()
		await get_tree().create_timer(1.0).timeout
		_start_level()

func _advance_level() -> void:
	current_level += 1
	if current_level >= 5:
		current_level = 0
		current_tier += 1
		lives = 3  # ← add this
		if current_tier >= difficulties.size():
			_game_complete()
			return
	player.reset_position()
	_start_level()

func _game_over() -> void:
	lives = 3
	current_level = 0
	current_tier = 0
	player.reset_position()
	hud.show_game_over()
	
	var retry = hud.get_node("HUD_Root/GameOverPanel/RestartButton")
	var overworld = hud.get_node("HUD_Root/GameOverPanel/OverworldButton")
	
	if not retry.pressed.is_connected(_on_restart):
		retry.pressed.connect(_on_restart)
	if not overworld.pressed.is_connected(_on_overworld):
		overworld.pressed.connect(_on_overworld)

func _game_complete() -> void:
	hud.show_message("YOU WIN!")


func _on_restart() -> void:
	hud.get_node("HUD_Root/GameOverPanel").visible = false
	tutorial_intro_done = false
	tutorial_first_fail_done = false
	tutorial_first_success_done = false
	if current_tier == 0:
		await _play_dialogue("res://features/luksong_baka/dialogues/tutorial_intro.dtl")
	_start_level()


func _on_overworld() -> void:
	get_tree().change_scene_to_file("res://features/overworld/overworld.tscn")
