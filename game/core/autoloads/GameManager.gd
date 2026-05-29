extends Node

# Luksong Baka
var luksong_baka_unlocked_tiers: Array = [0]
var luksong_baka_selected_tier: int = 0

# Patintero (your groupmate can add their vars here)
# var patintero_unlocked_levels: Array = [0]

# Tumbang Preso (same)
# var tumbang_preso_unlocked_levels: Array = [0]

const SAVE_PATH = "user://kalye404_save.cfg"

func _ready() -> void:
	load_progress()

func unlock_luksong_baka_tier(tier: int) -> void:
	if tier not in luksong_baka_unlocked_tiers:
		luksong_baka_unlocked_tiers.append(tier)
	save_progress()

func start_luksong_baka(tier: int = 0) -> void:
	luksong_baka_selected_tier = tier
	get_tree().change_scene_to_file("res://features/luksong_baka/main.tscn")

func save_progress() -> void:
	var config = ConfigFile.new()
	config.set_value("luksong_baka", "unlocked_tiers", luksong_baka_unlocked_tiers)
	config.save(SAVE_PATH)

func load_progress() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		luksong_baka_unlocked_tiers = config.get_value("luksong_baka", "unlocked_tiers", [0])

func reset_progress() -> void:
	luksong_baka_unlocked_tiers = [0]
	luksong_baka_selected_tier = 0
	save_progress()
