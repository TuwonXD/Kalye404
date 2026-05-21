extends Node2D

# These match the 5 level animations: level_1 to level_5
const LEVEL_ANIMS = ["level_1", "level_2", "level_3", "level_4", "level_5"]

@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	# Start at the lowest position
	anim_player.play("level_1")

func rise_to_level(level: int) -> void:
	# level is 0-indexed so level 0 = level_1 anim, etc.
	var anim_name = LEVEL_ANIMS[clamp(level, 0, LEVEL_ANIMS.size() - 1)]
	
	# Play the rise transition first, then settle into the level pose
	anim_player.play("rise")
	await anim_player.animation_finished
	anim_player.play(anim_name)
