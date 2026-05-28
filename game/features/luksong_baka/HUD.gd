extends CanvasLayer

@onready var hearts_label = $HUD_Root/HeartsLabel
@onready var level_label = $HUD_Root/LevelLabel
@onready var message_label = $HUD_Root/MessageLabel
@onready var game_over_panel = $HUD_Root/GameOverPanel

signal restart_pressed
signal overworld_pressed

func _ready() -> void:
	message_label.visible = false
	game_over_panel.visible = false

func update_display(lives: int, tier_name: String, level: int) -> void:
	hearts_label.text = "❤️".repeat(lives)
	level_label.text = "%s - Level %d" % [tier_name, level]

func show_message(text: String, duration: float = 2.0) -> void:
	message_label.text = text
	message_label.visible = true
	await get_tree().create_timer(duration).timeout
	message_label.visible = false

func show_game_over() -> void:
	game_over_panel.visible = true

func _on_restart_button_pressed() -> void:
	game_over_panel.visible = false
	restart_pressed.emit()

func _on_overworld_button_pressed() -> void:
	overworld_pressed.emit()
