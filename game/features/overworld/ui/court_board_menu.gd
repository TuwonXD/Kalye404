extends Control

@onready var game_selector: OptionButton = $Panel/GameSelector
@onready var tutorial_btn: Button = $Panel/VBoxContainer/TutorialButton
@onready var bronze_btn: Button = $Panel/VBoxContainer/BronzeButton
@onready var silver_btn: Button = $Panel/VBoxContainer/SilverButton
@onready var champion_btn: Button = $Panel/VBoxContainer/ChampionButton
@onready var close_btn: Button = $Panel/CloseButton

func _ready():
	# 1. Setup the Dropdown (OptionButton)
	game_selector.clear()
	game_selector.add_item("Tumbang Preso", 0)
	game_selector.add_item("Patintero", 1)
	game_selector.add_item("Luksong Baka", 2)
	
	# 2. Connect Signals
	game_selector.item_selected.connect(_on_game_selected)
	tutorial_btn.pressed.connect(func(): _launch_game(0))
	bronze_btn.pressed.connect(func(): _launch_game(1))
	silver_btn.pressed.connect(func(): _launch_game(2))
	champion_btn.pressed.connect(func(): _launch_game(3))
	close_btn.pressed.connect(func(): queue_free())
	
	# Initialize first view intelligently based on Story State
	var default_index = 0
	if GameManager.current_story_state >= GameManager.StoryState.DAY2_INTRO and GameManager.current_story_state < GameManager.StoryState.DAY3_INTRO:
		default_index = 1
	elif GameManager.current_story_state >= GameManager.StoryState.DAY3_INTRO:
		default_index = 2
		
	game_selector.select(default_index)
	_on_game_selected(default_index)

func _on_game_selected(index: int):
	var unlock_arr: Array = []
	if index == 0:
		unlock_arr = GameManager.tumbang_preso_unlocked_tiers
	elif index == 1:
		unlock_arr = GameManager.patintero_unlocked_tiers
	elif index == 2:
		unlock_arr = GameManager.luksong_baka_unlocked_tiers
		
	var highest_unlocked = _get_max_in_array(unlock_arr)
	
	# Disable buttons strictly based on their existence in the array
	tutorial_btn.disabled = not (0 in unlock_arr)
	bronze_btn.disabled = not (1 in unlock_arr or highest_unlocked >= 1)
	silver_btn.disabled = not (2 in unlock_arr or highest_unlocked >= 2)
	champion_btn.disabled = not (3 in unlock_arr or highest_unlocked >= 3)
	
	# DEBUG: Uncomment this to force-enable all buttons locally to test their launches
	# bronze_btn.disabled = false
	# silver_btn.disabled = false
	# champion_btn.disabled = false

func _get_max_in_array(arr: Array) -> int:
	var max_val = 0
	for val in arr:
		if val > max_val: 
			max_val = val
	return max_val

func _launch_game(tier: int):
	# If they selected Champion (Tier 3), it's a Boss Battle!
	if tier == 3:
		if game_selector.selected == 0 and GameManager.current_story_state == GameManager.StoryState.DAY1_BOSS:
			queue_free() # Close the menu
			Dialogic.start("act1_pre_game")
			return
		elif game_selector.selected == 1 and GameManager.current_story_state == GameManager.StoryState.DAY2_BOSS:
			queue_free()
			Dialogic.start("act2_pre_game")
			return
		elif game_selector.selected == 2 and GameManager.current_story_state == GameManager.StoryState.DAY3_BOSS:
			queue_free()
			Dialogic.start("act3_pre_game")
			return
			
	# Default launch for grinds or replaying bosses
	GameManager.start_minigame(game_selector.selected, tier)
