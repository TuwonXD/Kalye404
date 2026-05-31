extends Node2D

@onready var sprite = $Sprite2D

const BASE_PATH = "res://features/overworld/assets/luksong baka kids a-e level 1-5/"

const TIER_SPRITES = [
	# Tier 0 - Tutorial (kid a)
	["kid a/kid A level 1.png", "kid a/kid A level 2.png", "kid a/kid A level 3.png", "kid a/kid A level 4.png", "kid a/kid A level 5.png"],
	# Tier 1 - Bronze (kid b)
	["kid b/kid B level 1.png", "kid b/kid B level 2.png", "kid b/kid B level 3.png", "kid b/kid B level 4.png", "kid b/kid B level 5.png"],
	# Tier 2 - Silver (kid c)
	["kid c/kid C level 1.png", "kid c/kid C level 2.png", "kid c/kid C level 3.png", "kid c/kid C level 4.png", "kid c/kid C level 5.png"],
	# Tier 3 - Champion (kuya talon)``
	["kuya talon/kuya talon level 1.png", "kuya talon/kuya talon level 2.png", "kuya talon/kuya talon level 3.png", "kuya talon/kuya talon level 4.png", "kuya talon/kuya talon level 5.png"],
]

var current_tier: int = 0

func _ready() -> void:
	set_level_sprite(0)

func set_tier(tier: int) -> void:
	current_tier = tier
	set_level_sprite(0)

func set_level_sprite(level: int) -> void:
	var path = BASE_PATH + TIER_SPRITES[current_tier][clamp(level, 0, 4)]
	sprite.texture = load(path)

func rise_to_level(level: int) -> void:
	set_level_sprite(level)
