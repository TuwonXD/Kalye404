extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("throw"):
		animated_sprite.sprite_frames.set_animation_loop("throw", false)
	if animated_sprite and not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)
	play_idle_with_slipper()


func play_animation(animation_name: String) -> void:
	if animated_sprite == null:
		return

	if animated_sprite.animation == animation_name and animated_sprite.is_playing():
		return

	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)


func play_throw() -> void:
	play_animation("throw")


func play_idle() -> void:
	play_animation("idle-w-slipper")


func play_idle_with_slipper() -> void:
	play_animation("idle-w-slipper")


func _on_animation_finished() -> void:
	if animated_sprite and animated_sprite.animation == "throw":
		play_idle_with_slipper()
