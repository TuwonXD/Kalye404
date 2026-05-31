extends Control

@onready var main_menu_btn = $MainMenuBtn

func _ready():
	# Make sure mouse is visible in case it was hidden during overworld
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	main_menu_btn.grab_focus()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://features/main_menu/main_menu.tscn")
