extends Area3D

var _menu_scene = preload("res://features/overworld/ui/court_board_menu.tscn")

# 1. Provide the name for the UI prompt
func has_dialogue() -> bool:
	# Only interactable AFTER they finish the tutorial
	return GameManager.current_story_state >= GameManager.StoryState.DAY1_TUMBANG_GRIND

# 2. Hook into the player_interaction.gd's detection logic
func interact():
	if get_tree().current_scene.has_node("CourtBoardMenu"):
		return
	
	var menu = _menu_scene.instantiate()
	# Ensure the menu runs even when the game is paused
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	get_tree().current_scene.add_child(menu)
	# Important naming for safety
	menu.name = "CourtBoardMenu"
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Pause the game so player can't move and UI stops updating
	var scene_tree = get_tree()
	scene_tree.paused = true
	
	var hud = scene_tree.current_scene.find_child("ObjectiveHUD", true, false)
	var interact_ui = scene_tree.current_scene.find_child("InteractUI", true, false)
	
	if hud: hud.visible = false
	if interact_ui: interact_ui.visible = false
	
	menu.tree_exited.connect(func():
		scene_tree.paused = false
		if hud: hud.visible = true
		if interact_ui: interact_ui.visible = true
	)
