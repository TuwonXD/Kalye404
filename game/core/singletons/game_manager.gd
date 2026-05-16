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

var current_story_state: StoryState = StoryState.DAY1_INTRO
var game_progress: Dictionary = {
	"tumbang": 0, # 0=Locked, 1=Tutorial, 2=Bronze, 3=Silver, 4=Champion
	"patintero": 0,
	"luksong": 0
}
var player_position: Vector3 = Vector3.ZERO
var SAVE_PATH = "user://kalye404_save.json"

func _ready():
	load_game()

func advance_story_state():
	if current_story_state < StoryState.EPILOGUE:
		current_story_state = (current_story_state + 1) as StoryState
		
		# Auto-unlock things during dev skip so the logic doesn't break
		match current_story_state:
			StoryState.DAY1_BOSS: game_progress["tumbang"] = max(game_progress["tumbang"], 3)
			StoryState.DAY2_BOSS: game_progress["patintero"] = max(game_progress["patintero"], 3)
			StoryState.DAY3_BOSS: game_progress["luksong"] = max(game_progress["luksong"], 3)
			
		emit_signal("story_state_changed", current_story_state)
		save_game()
		print("DEV SKIP: Advanced to state: ", current_story_state)

func _input(event):
	# F12 Dev Skip
	if event.is_action_pressed("dev_skip"):
		advance_story_state()

func set_story_state(new_state: StoryState):
	current_story_state = new_state
	emit_signal("story_state_changed", current_story_state)
	save_game()

func save_game():
	var save_dict = {
		"current_story_state": current_story_state,
		"game_progress": game_progress,
		"player_pos_x": player_position.x,
		"player_pos_y": player_position.y,
		"player_pos_z": player_position.z
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict))
		file.close()

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
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
