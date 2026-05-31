extends CanvasLayer

@onready var hearts_label = $HUD_Root/HeartsLabel
@onready var level_label = $HUD_Root/LevelLabel
@onready var message_label = $HUD_Root/MessageLabel
@onready var game_over_panel = $HUD_Root/GameOverPanel
@onready var tier_complete_panel = $HUD_Root/TierCompletePanel

signal restart_pressed
signal overworld_pressed
signal next_tier_pressed

func _ready() -> void:
	message_label.visible = false
	game_over_panel.visible = false
	tier_complete_panel.visible = false
	
	# Connect all buttons directly
	$HUD_Root/GameOverPanel/RestartButton.pressed.connect(_on_restart_button_pressed)
	$HUD_Root/GameOverPanel/OverWorldButton.pressed.connect(_on_overworld_button_pressed)
	$HUD_Root/TierCompletePanel/NextTierButton.pressed.connect(_on_next_tier_button_pressed)
	$HUD_Root/TierCompletePanel/OverWorldButton2.pressed.connect(_on_overworld_button_2_pressed)

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

func show_tier_complete(is_last_tier: bool) -> void:
	tier_complete_panel.visible = true
	var next_btn = tier_complete_panel.get_node("NextTierButton")
	next_btn.visible = not is_last_tier

func _on_restart_button_pressed() -> void:
	game_over_panel.visible = false
	restart_pressed.emit()

func _on_overworld_button_pressed() -> void:
	overworld_pressed.emit()

func _on_next_tier_button_pressed() -> void:
	tier_complete_panel.visible = false
	next_tier_pressed.emit()

func _on_overworld_button_2_pressed() -> void:
	overworld_pressed.emit()
