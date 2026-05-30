extends Control

@onready var continue_btn = $VBoxContainer/ContinueBtn
@onready var new_game_btn = $VBoxContainer/NewGameBtn
@onready var quit_btn = $VBoxContainer/QuitBtn

func _ready():
	# Check if save file exists
	if GameManager.has_save_file():
		continue_btn.disabled = false
		continue_btn.grab_focus()
	else:
		continue_btn.disabled = true
		new_game_btn.grab_focus()

	# Connect buttons
	continue_btn.pressed.connect(_on_continue_pressed)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func _on_continue_pressed():
	_transition_to_game(false)

var new_game_dialog: ConfirmationDialog = null

func _on_new_game_pressed():
	if GameManager.has_save_file():
		_show_new_game_warning()
	else:
		_transition_to_game(true)

func _show_new_game_warning():
	if is_instance_valid(new_game_dialog):
		return
		
	new_game_dialog = ConfirmationDialog.new()
	new_game_dialog.dialog_text = "Are you sure you want to start a New Game?\nYour current progress will be reset."
	new_game_dialog.get_ok_button().text = "Yes"
	new_game_dialog.get_cancel_button().text = "Cancel"
	
	new_game_dialog.confirmed.connect(_start_new_game)
	new_game_dialog.canceled.connect(_cancel_new_game)
	new_game_dialog.close_requested.connect(_cancel_new_game)
	
	add_child(new_game_dialog)
	new_game_dialog.popup_centered()

func _start_new_game():
	if is_instance_valid(new_game_dialog):
		new_game_dialog.queue_free()
	_transition_to_game(true)

func _transition_to_game(is_new_game: bool):
	# Disable buttons so player doesn't double click
	continue_btn.disabled = true
	new_game_btn.disabled = true
	quit_btn.disabled = true
	
	if is_new_game:
		GameManager.current_story_state = GameManager.StoryState.DAY1_INTRO
		GameManager.game_progress = {"tumbang": 0, "patintero": 0, "luksong": 0}
		GameManager.player_position = Vector3(0.0, 0.0, 0.0)
		GameManager.save_game()
	
	# Go directly to overworld, no fade
	get_tree().change_scene_to_file("res://features/overworld/overworld.tscn")

func _cancel_new_game():
	if is_instance_valid(new_game_dialog):
		new_game_dialog.queue_free()

func _on_quit_pressed():
	get_tree().quit()
