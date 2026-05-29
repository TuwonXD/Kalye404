extends Node

signal story_state_changed(new_state)

enum StoryState {
	DAY1_INTRO,
	DAY1_ESKINITA,
	DAY1_TUMBANG_TUTORIAL,
	DAY1_TUMBANG_GRIND,
	DAY1_BOSS,
	DAY1_OUTRO,
	DAY2_INTRO,
	DAY2_PATINTERO_TUTORIAL,
	DAY2_PATINTERO_GRIND,
	DAY2_BOSS,
	DAY2_OUTRO,
	DAY3_INTRO,
	DAY3_LUKSONG_TUTORIAL,
	DAY3_LUKSONG_GRIND,
	DAY3_BOSS,
	EPILOGUE
}

# --- Overworld State ---
var current_story_state: StoryState = StoryState.DAY1_INTRO
var game_progress: Dictionary = {
	"tumbang": 0, # 0=Locked, 1=Tutorial, 2=Bronze, 3=Silver, 4=Champion
	"patintero": 0,
	"luksong": 0
}
var player_position: Vector3 = Vector3.ZERO
var is_dialogue_active: bool = false


# --- Minigame (Luksong Baka) State ---
var luksong_baka_unlocked_tiers: Array = [0]
var luksong_baka_selected_tier: int = 0

# Patintero (your groupmate can add their vars here)
# var patintero_unlocked_levels: Array = [0]

# Tumbang Preso (same)
# var tumbang_preso_unlocked_levels: Array = [0]


const SAVE_PATH_CFG = "user://kalye404_save.cfg"
const SAVE_PATH_JSON = "user://kalye404_save.json"

func _ready() -> void:
	load_progress()
	load_game()
	# Connect to Dialogic signals to advance story naturally
	if Dialogic:
		Dialogic.signal_event.connect(_on_dialogic_signal)
		Dialogic.timeline_started.connect(func(): is_dialogue_active = true)
		Dialogic.timeline_ended.connect(func(): is_dialogue_active = false)

# ==========================================
# MINIGAME METHODS
# ==========================================
func unlock_luksong_baka_tier(tier: int) -> void:
	if tier not in luksong_baka_unlocked_tiers:
		luksong_baka_unlocked_tiers.append(tier)
	save_progress()

func start_luksong_baka(tier: int = 0) -> void:
	luksong_baka_selected_tier = tier
	get_tree().change_scene_to_file("res://features/luksong_baka/main.tscn")

# ==========================================
# SAVE / LOAD ARCHITECTURE (MINIGAMES)
# ==========================================
func save_progress() -> void:
	var config = ConfigFile.new()
	# Minigames
	config.set_value("luksong_baka", "unlocked_tiers", luksong_baka_unlocked_tiers)
	config.save(SAVE_PATH_CFG)

func load_progress() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH_CFG) == OK:
		luksong_baka_unlocked_tiers = config.get_value("luksong_baka", "unlocked_tiers", [0])

func reset_progress() -> void:
	luksong_baka_unlocked_tiers = [0]
	luksong_baka_selected_tier = 0
	save_progress()

# ==========================================
# OVERWORLD METHODS
# ==========================================
func _on_dialogic_signal(argument: String):
	print("GameManager received Dialogic signal: ", argument)
	match argument:
		"start_overworld_act1":
			if current_story_state == StoryState.DAY1_INTRO: advance_story_state()
		"eskinita_intro_done":
			if current_story_state == StoryState.DAY1_ESKINITA: advance_story_state()
		"start_tutorial_tumbang_preso":
			if current_story_state == StoryState.DAY1_TUMBANG_TUTORIAL: advance_story_state()
		"end_act_1":
			if current_story_state == StoryState.DAY1_BOSS: advance_story_state()
		"fade_to_day_2":
			if current_story_state == StoryState.DAY1_OUTRO: advance_story_state()
		"start_overworld_act2":
			if current_story_state == StoryState.DAY2_INTRO: advance_story_state()
		"start_tutorial_patintero":
			if current_story_state == StoryState.DAY2_PATINTERO_TUTORIAL: advance_story_state()
		"end_act_2":
			if current_story_state == StoryState.DAY2_BOSS: advance_story_state()
		"fade_to_day_3":
			if current_story_state == StoryState.DAY2_OUTRO: advance_story_state()
		"start_overworld_act3":
			if current_story_state == StoryState.DAY3_INTRO: advance_story_state()
		"start_tutorial_luksong_baka":
			if current_story_state == StoryState.DAY3_LUKSONG_TUTORIAL: advance_story_state()
		"end_act_3":
			if current_story_state == StoryState.DAY3_BOSS: advance_story_state()
		"roll_credits":
			print("GAME FINISHED! Roll Credits.")

func advance_story_state():
	if current_story_state < StoryState.EPILOGUE:
		current_story_state = (current_story_state + 1) as StoryState
		
		# Auto-unlock things during dev skip so the logic doesn't break
		match current_story_state:
			StoryState.DAY1_BOSS: game_progress["tumbang"] = max(game_progress["tumbang"], 4)
			StoryState.DAY2_BOSS: game_progress["patintero"] = max(game_progress["patintero"], 4)
			StoryState.DAY3_BOSS: game_progress["luksong"] = max(game_progress["luksong"], 4)
			
		emit_signal("story_state_changed", current_story_state)
		save_game()
		print("STORY ADVANCED TO: ", current_story_state)

func reverse_story_state():
	if current_story_state > 0:
		current_story_state = (current_story_state - 1) as StoryState
		emit_signal("story_state_changed", current_story_state)
		save_game()
		print("DEV REVERSE: Went back to state: ", current_story_state)

func _input(event):
	# F12 Dev Skip Forward
	if event.is_action_pressed("dev_skip"):
		advance_story_state()
	# F11 Dev Skip Backward
	if event.is_action_pressed("dev_reverse"):
		reverse_story_state()

func set_story_state(new_state: StoryState):
	current_story_state = new_state
	emit_signal("story_state_changed", current_story_state)
	save_game()

# ==========================================
# SAVE / LOAD ARCHITECTURE (OVERWORLD)
# ==========================================
func save_game():
	var save_dict = {
		"current_story_state": current_story_state,
		"game_progress": game_progress,
		"player_pos_x": player_position.x,
		"player_pos_y": player_position.y,
		"player_pos_z": player_position.z
	}
	var file = FileAccess.open(SAVE_PATH_JSON, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict))
		file.close()

func load_game():
	if FileAccess.file_exists(SAVE_PATH_JSON):
		var file = FileAccess.open(SAVE_PATH_JSON, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		
		var parsed = JSON.parse_string(content)
		if parsed and typeof(parsed) == TYPE_DICTIONARY:
			current_story_state = parsed.get("current_story_state", StoryState.DAY1_INTRO)
			game_progress = parsed.get("game_progress", {"tumbang": 0, "patintero": 0, "luksong": 0})
			player_position = Vector3(
				parsed.get("player_pos_x", 0.0),
				parsed.get("player_pos_y", 0.0),
				parsed.get("player_pos_z", 0.0)
			)
			emit_signal("story_state_changed", current_story_state)
