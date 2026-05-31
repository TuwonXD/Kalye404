extends Node2D

@export var difficulties: Array[LuksongBakaDifficulty] = []

var tutorial_intro_done: bool = false
var tutorial_first_fail_done: bool = false
var tutorial_first_success_done: bool = false

@onready var player = $Player
@onready var baka = $Baka
@onready var hud = $HUD
@onready var qte_controller = $QTEController

var current_tier: int = 0
var current_level: int = 0
var lives: int = 3

signal match_ended(result: String)

func _ready() -> void:
	# GameManager.reset_progress() # BUG FIX: Prevented script from clearing save data on load 
	current_tier = GameManager.luksong_baka_selected_tier
	lives = 3
	current_level = 0
	hud.restart_pressed.connect(_on_restart)
	hud.overworld_pressed.connect(_on_overworld)
	hud.next_tier_pressed.connect(_on_next_tier)
	
	if GameManager.bypass_minigame_menu:
		GameManager.bypass_minigame_menu = false
	_on_tier_selected(current_tier)

func _on_tier_selected(tier: int) -> void:
	current_tier = tier
	lives = 3
	current_level = 0
	_reset_tutorial_flags()
	if current_tier == 0:
		await _play_dialogue("res://features/luksong_baka/dialogues/tutorial_intro.dtl")
	elif current_tier == 3:
		await _play_dialogue("res://features/luksong_baka/dialogues/champion_intro.dtl")
	_start_level()

func _reset_tutorial_flags() -> void:
	tutorial_intro_done = false
	tutorial_first_fail_done = false
	tutorial_first_success_done = false

func _start_level() -> void:
	var difficulty = difficulties[current_tier]
	hud.update_display(lives, difficulty.tier_name, current_level + 1)
	baka.set_tier(current_tier)  # add this
	baka.rise_to_level(current_level)
	player.start_running()

func _play_dialogue(timeline: String) -> void:
	Dialogic.start(timeline)
	await Dialogic.timeline_ended

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
	if current_tier == 0 and not tutorial_first_success_done:
		tutorial_first_success_done = true
		await get_tree().create_timer(1.0).timeout
		await _play_dialogue("res://features/luksong_baka/dialogues/tutorial_success.dtl")
	elif current_tier == 3 and not tutorial_first_success_done:
		tutorial_first_success_done = true
		await get_tree().create_timer(1.0).timeout
		await _play_dialogue("res://features/luksong_baka/dialogues/champion_success.dtl")
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
	elif current_tier == 3 and not tutorial_first_fail_done:
		tutorial_first_fail_done = true
		await _play_dialogue("res://features/luksong_baka/dialogues/champion_fail.dtl")
	await get_tree().create_timer(2.5).timeout
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
		GameManager.unlock_luksong_baka_tier(current_tier + 1)
		var is_last = current_tier >= difficulties.size() - 1
		if is_last:
			_game_complete()
			return
		match_ended.emit("tier_complete")
	else:
		player.reset_position()
		_start_level()

func _game_over() -> void:
	match_ended.emit("lose")

func _game_complete() -> void:
	match_ended.emit("win")

func _on_restart() -> void:
	hud.get_node("HUD_Root/GameOverPanel").visible = false
	_reset_tutorial_flags()
	if current_tier == 0:
		await _play_dialogue("res://features/luksong_baka/dialogues/tutorial_intro.dtl")
	_start_level()

func _on_next_tier() -> void:
	current_tier += 1
	lives = 3
	current_level = 0
	_reset_tutorial_flags()
	player.reset_position()
	await get_tree().create_timer(0.5).timeout
	_start_level()

func _on_overworld() -> void:
	get_tree().change_scene_to_file("res://features/overworld/overworld.tscn")
