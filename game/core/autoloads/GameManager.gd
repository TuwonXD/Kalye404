extends Node

# Set this to true when testing minigames via F6 so the buttons aren't grayed out!
const F6_TEST_MODE: bool = true

signal story_state_changed(new_state)

enum StoryState {
	DAY1_INTRO,
	DAY1_ESKINITA,
	DAY1_TUMBANG_TUTORIAL,
	DAY1_TUMBANG_GRIND,
	DAY1_BOSS,
	DAY1_OUTRO,
	DAY2_INTRO,
	DAY2_SIMBAHAN,
	DAY2_PATINTERO_TUTORIAL,
	DAY2_PATINTERO_GRIND,
	DAY2_BOSS,
	DAY2_OUTRO,
	DAY3_INTRO,
	DAY3_ERRAND,
	DAY3_LUKSONG_TUTORIAL,
	DAY3_LUKSONG_GRIND,
	DAY3_BOSS,
	EPILOGUE,
	FINISHED
}

# --- State & Story Variables ---
var current_story_state: StoryState = StoryState.DAY1_INTRO
var game_progress: Dictionary = {
	"tumbang": 0, # 0=Locked, 1=Tutorial, 2=Bronze, 3=Silver, 4=Champion
	"patintero": 0,
	"luksong": 0
}
var player_position: Vector3 = Vector3.ZERO
var is_dialogue_active: bool = false
var pending_dialogue: String = ""

# --- Minigame State ---
var luksong_baka_unlocked_tiers: Array = []
var luksong_baka_selected_tier: int = 0

var patintero_unlocked_tiers: Array = []
var tumbang_preso_unlocked_tiers: Array = []


const SAVE_PATH_JSON = "user://kalye404_save.json"

var _fade_rect: ColorRect

func _ready() -> void:
	# 1. Setup Global Fade Layer
	var canvas = CanvasLayer.new()
	canvas.layer = 128 # High priority to cover UI
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color.BLACK
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.modulate.a = 1.0
	canvas.add_child(_fade_rect)
	add_child(canvas)
	
	# Fix for F6 direct scene testing (auto-fade out if not in overworld)
	call_deferred("_check_f6_fade")

func _check_f6_fade() -> void:
	if get_tree().current_scene and get_tree().current_scene.name != "Overworld":
		var tween = create_tween()
		tween.tween_property(_fade_rect, "modulate:a", 0.0, 1.0)

	# 2. Load & Sync
	load_game()
	_sync_arrays_from_dict() # Guarantee arrays sync even if no save exists

	# 3. Connect to Dialogic
	if Dialogic:
		Dialogic.signal_event.connect(_on_dialogic_signal)
		Dialogic.timeline_started.connect(func(): is_dialogue_active = true)
		Dialogic.timeline_ended.connect(func(): is_dialogue_active = false)

# ==========================================
# MINIGAME METHODS (Unified Master Hooks)
# ==========================================
func complete_minigame_tier(game_id: String, tier_beaten: int):
	# tier 0 (tut) beaten -> progress 2 (Bronze). tier 1 beaten -> progress 3 (Silver)
	var new_progress = tier_beaten + 2 
	if game_progress.has(game_id) and game_progress[game_id] < new_progress:
		game_progress[game_id] = new_progress
		
	if tier_beaten == 2:
		# Unlocked the Boss! Auto-advance state to the Boss objective
		if game_id == "tumbang" and current_story_state == StoryState.DAY1_TUMBANG_GRIND:
			advance_story_state()
		elif game_id == "patintero" and current_story_state == StoryState.DAY2_PATINTERO_GRIND:
			advance_story_state()
		elif game_id == "luksong" and current_story_state == StoryState.DAY3_LUKSONG_GRIND:
			advance_story_state()
			
	_sync_arrays_from_dict()
	save_game()

func unlock_luksong_baka_tier(tier: int) -> void:
	# Teammate's legacy code calls this with the *target* tier they want to unlock.
	# Example: Beating Tier 0 triggers `unlock(1)`. If target is 1, overworld progress should be 2.
	var target_progress = tier + 1
	if game_progress["luksong"] < target_progress:
		game_progress["luksong"] = target_progress
	_sync_arrays_from_dict()
	save_game()

var bypass_minigame_menu: bool = false

func fade_and_start_minigame(game_index: int, tier: int) -> void:
	if _fade_rect:
		var tween = create_tween()
		tween.tween_property(_fade_rect, "modulate:a", 1.0, 0.5)
		await tween.finished
		
		start_minigame(game_index, tier)
		
		var tween2 = create_tween()
		tween2.tween_property(_fade_rect, "modulate:a", 0.0, 0.5)
	else:
		start_minigame(game_index, tier)

func fade_and_change_scene(path: String) -> void:
	# Save before leaving the overworld
	save_game()
	if _fade_rect:
		var tween = create_tween()
		tween.tween_property(_fade_rect, "modulate:a", 1.0, 0.5)
		await tween.finished
		
		get_tree().change_scene_to_file(path)
		
		var tween2 = create_tween()
		tween2.tween_property(_fade_rect, "modulate:a", 0.0, 0.5)
	else:
		get_tree().change_scene_to_file(path)

func start_minigame(game_index: int, tier: int):
	# Save position before minigame
	save_game()
	
	if game_index == 0:
		_start_tumbang_preso(tier)
	elif game_index == 1:
		_start_patintero(tier)
	elif game_index == 2:
		bypass_minigame_menu = true
		start_luksong_baka(tier)

func _start_tumbang_preso(tier: int) -> void:
	var packed = load("res://features/tumbang-preso/scenes/tumbang_preso.tscn")
	var scene = packed.instantiate()
	
	if tier == 0: scene.setup(20, 20, 30, 30)
	elif tier == 1: scene.setup(50, 50, 60, 60)
	elif tier == 2: scene.setup(80, 80, 90, 75)
	elif tier == 3: scene.setup(95, 90, 100, 100)
	
	get_tree().root.add_child(scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = scene
	
	# Hook up win condition to auto-close
	scene.player_max_score_reached.connect(func(_score):
		complete_minigame_tier("tumbang", tier)
		if tier == 0: pending_dialogue = "tutorial_tumbang_done"
		elif tier == 3: pending_dialogue = "act1_post_win"
		fade_and_change_scene("res://features/overworld/overworld.tscn")
	)
	
	# Hook up lose condition
	scene.enemy_max_score_reached.connect(func(_score):
		if tier == 3: pending_dialogue = "act1_lose"
		fade_and_change_scene("res://features/overworld/overworld.tscn")
	)

func _start_patintero(tier: int) -> void:
	var packed = load("res://features/patintero/patintero.tscn")
	var scene = packed.instantiate()
	
	var diff_res = null
	if tier == 0: diff_res = load("res://features/patintero/difficulty/tutorial.tres")
	elif tier == 1: diff_res = load("res://features/patintero/difficulty/bronze.tres")
	elif tier == 2: diff_res = load("res://features/patintero/difficulty/silver.tres")
	elif tier == 3: diff_res = load("res://features/patintero/difficulty/champion.tres")
	
	if diff_res: scene.setup(diff_res)
	else: scene.setup(load("res://features/patintero/difficulty/bronze.tres"))
	
	get_tree().root.add_child(scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = scene
	
	# Hook up match condition to auto-close
	scene.match_ended.connect(func(result: String):
		if result == "win":
			complete_minigame_tier("patintero", tier)
			if tier == 0: pending_dialogue = "tutorial_patintero_done"
			elif tier == 3: pending_dialogue = "act2_post_win"
		else:
			if tier == 3: pending_dialogue = "act2_lose"
		fade_and_change_scene("res://features/overworld/overworld.tscn")
	)

func start_luksong_baka(tier: int = 0) -> void:
	luksong_baka_selected_tier = tier
	get_tree().change_scene_to_file("res://features/luksong_baka/main.tscn")

# ==========================================
# STATE FORMATTING ENGINE
# ==========================================
func _sync_arrays_from_dict():
	luksong_baka_unlocked_tiers = _generate_tiers("luksong")
	patintero_unlocked_tiers = _generate_tiers("patintero")
	tumbang_preso_unlocked_tiers = _generate_tiers("tumbang")
	
	if F6_TEST_MODE:
		luksong_baka_unlocked_tiers = [0, 1, 2, 3]
		patintero_unlocked_tiers = [0, 1, 2, 3]
		tumbang_preso_unlocked_tiers = [0, 1, 2, 3]
		return # Bypass locks so all minigame tiers are clickable in F6 testing!
		
	# Force-lock tiers if the story hasn't progressed enough (prevents old save files from bypassing the story)
	if current_story_state < StoryState.DAY1_TUMBANG_GRIND:
		tumbang_preso_unlocked_tiers.clear()
	if current_story_state < StoryState.DAY2_PATINTERO_GRIND:
		patintero_unlocked_tiers.clear()
	if current_story_state < StoryState.DAY3_LUKSONG_GRIND:
		luksong_baka_unlocked_tiers.clear()

func _generate_tiers(game_id: String) -> Array:
	var progress = game_progress.get(game_id, 0)
	if progress == 0:
		return [] # 0 progress means completely locked
		
	var arr = []
	# Converts Overworld Progress (1, 2, 3...) to Max Tier Index (0, 1, 2)
	var max_tier = progress - 1
	for i in range(max_tier + 1):
		arr.append(i)
	return arr

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
			if current_story_state == StoryState.DAY1_TUMBANG_TUTORIAL: 
				advance_story_state()
				fade_and_start_minigame(0, 0)
		"start_tumbang_preso_game":
			# This signal comes from act1_pre_game.dtl (Boss fight)
			fade_and_start_minigame(0, 3)
		"retry_tumbang_preso":
			pass # Do nothing, stay in overworld so player can manually trigger via Board
		"end_act_1":
			if current_story_state == StoryState.DAY1_BOSS: advance_story_state()
		"fade_to_day_2":
			if current_story_state == StoryState.DAY1_OUTRO: 
				advance_story_state() # Becomes DAY2_INTRO
				fade_and_change_scene("res://features/overworld/overworld.tscn")
		"start_overworld_act2":
			if current_story_state == StoryState.DAY2_INTRO: advance_story_state()
		"simbahan_intro_done":
			if current_story_state == StoryState.DAY2_SIMBAHAN: advance_story_state()
		"start_tutorial_patintero":
			if current_story_state == StoryState.DAY2_PATINTERO_TUTORIAL: 
				advance_story_state()
				fade_and_start_minigame(1, 0)
		"start_patintero_game":
			fade_and_start_minigame(1, 3)
		"retry_patintero":
			pass # Do nothing, stay in overworld
		"end_act_2":
			if current_story_state == StoryState.DAY2_BOSS: advance_story_state()
		"fade_to_day_3":
			if current_story_state == StoryState.DAY2_OUTRO: 
				advance_story_state() # Becomes DAY3_INTRO
				fade_and_change_scene("res://features/overworld/overworld.tscn")
		"start_overworld_act3":
			if current_story_state == StoryState.DAY3_INTRO: advance_story_state()
		"errand_intro_done":
			if current_story_state == StoryState.DAY3_ERRAND: advance_story_state()
		"start_tutorial_luksong_baka":
			if current_story_state == StoryState.DAY3_LUKSONG_TUTORIAL: 
				advance_story_state()
				fade_and_start_minigame(2, 0)
		"start_luksong_baka_game":
			fade_and_start_minigame(2, 3)
		"retry_luksong_baka":
			pass # Do nothing, stay in overworld
		"end_act_3":
			if current_story_state == StoryState.DAY3_BOSS: advance_story_state()
		"roll_credits":
			print("GAME FINISHED! Roll Credits.")
			if current_story_state == StoryState.EPILOGUE: advance_story_state()

func advance_story_state():
	if current_story_state < StoryState.FINISHED:
		current_story_state = (current_story_state + 1) as StoryState
		_enforce_story_bounds()
		_sync_arrays_from_dict()
		emit_signal("story_state_changed", current_story_state)
		save_game()
		print("STORY ADVANCED TO: ", current_story_state)

func reverse_story_state():
	if current_story_state > 0:
		current_story_state = (current_story_state - 1) as StoryState
		_enforce_story_bounds()
		_sync_arrays_from_dict()
		emit_signal("story_state_changed", current_story_state)
		save_game()
		print("DEV REVERSE: Went back to state: ", current_story_state)

func _enforce_story_bounds():
	# Tumbang Preso
	if current_story_state < StoryState.DAY1_TUMBANG_TUTORIAL: game_progress["tumbang"] = 0
	elif current_story_state < StoryState.DAY1_BOSS: game_progress["tumbang"] = max(game_progress["tumbang"], 1)
	else: game_progress["tumbang"] = max(game_progress["tumbang"], 4)
	# Patintero
	if current_story_state < StoryState.DAY2_PATINTERO_TUTORIAL: game_progress["patintero"] = 0
	elif current_story_state < StoryState.DAY2_BOSS: game_progress["patintero"] = max(game_progress["patintero"], 1)
	else: game_progress["patintero"] = max(game_progress["patintero"], 4)
	# Luksong Baka
	if current_story_state < StoryState.DAY3_LUKSONG_TUTORIAL: game_progress["luksong"] = 0
	elif current_story_state < StoryState.DAY3_BOSS: game_progress["luksong"] = max(game_progress["luksong"], 1)
	else: game_progress["luksong"] = max(game_progress["luksong"], 4)

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
			_sync_arrays_from_dict()
			emit_signal("story_state_changed", current_story_state)
