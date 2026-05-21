extends CanvasLayer

@onready var hearts_label = $HUD_Root/HeartsLabel
@onready var level_label = $HUD_Root/LevelLabel
@onready var message_label = $HUD_Root/MessageLabel

func _ready() -> void:
	message_label.visible = false

func update_display(lives: int, tier_name: String, level: int) -> void:
	# Show hearts as emojis
	hearts_label.text = "❤️".repeat(lives)
	# Show tier name and level number
	level_label.text = "%s - Level %d" % [tier_name, level]

func show_message(text: String, duration: float = 2.0) -> void:
	message_label.text = text
	message_label.visible = true
	await get_tree().create_timer(duration).timeout
	message_label.visible = false
