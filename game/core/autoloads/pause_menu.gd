extends CanvasLayer

@onready var resume_btn: Button = $Panel/VBoxContainer/ResumeBtn
@onready var quit_btn: Button = $Panel/VBoxContainer/QuitBtn

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_btn.pressed.connect(_on_resume)
	quit_btn.pressed.connect(_on_quit)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().current_scene.scene_file_path == "res://features/overworld/overworld.tscn":
			# Let the overworld handle its own pause menu if it has one
			return
		_toggle_pause()

func _toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		# When unpausing in a minigame, usually we want visible cursor anyway
		# The overworld will naturally capture the mouse in its own logic if needed
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_resume():
	_toggle_pause()

func _on_quit():
	_toggle_pause()
	# Ensure mouse is visible when returning to overworld so you can click the Court Board
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameManager.fade_and_change_scene("res://features/overworld/overworld.tscn")
