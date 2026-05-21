extends Node2D

# Difficulty resources
@export var difficulties: Array[LuksongBakaDifficulty] = []

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
	_start_level()

func _start_level() -> void:
	var difficulty = difficulties[current_tier]
	hud.update_display(lives, difficulty.tier_name, current_level + 1)
	player.start_running()

func on_player_reached_baka() -> void:
	var difficulty = difficulties[current_tier]
	var time_limit = difficulty.time_per_level[current_level]
	var seq_length = difficulty.sequence_length
	qte_controller.start_qte(seq_length, time_limit)

func on_qte_success() -> void:
	player.do_jump()
	baka.rise_to_level(current_level)
	await get_tree().create_timer(1.5).timeout
	_advance_level()

func on_qte_fail() -> void:
	lives -= 1
	hud.update_display(lives, difficulties[current_tier].tier_name, current_level + 1)
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
		if current_tier >= difficulties.size():
			_game_complete()
			return
	player.reset_position()
	_start_level()

func _game_over() -> void:
	lives = 3
	current_level = 0
	current_tier = 0
	hud.show_message("GAME OVER!")
	await get_tree().create_timer(2.0).timeout
	_start_level()

func _game_complete() -> void:
	hud.show_message("YOU WIN!")
