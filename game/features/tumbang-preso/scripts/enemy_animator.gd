extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if animated_sprite and animated_sprite.sprite_frames:
		for animation_name in ["throw", "run-up", "pickup", "run-down"]:
			if animated_sprite.sprite_frames.has_animation(animation_name):
				animated_sprite.sprite_frames.set_animation_loop(animation_name, false)
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


func play_run_up() -> void:
	play_animation("run-up")


func play_pickup() -> void:
	play_animation("pickup")


func play_run_down() -> void:
	play_animation("run-down")


func play_idle() -> void:
	play_animation("idle-w-slipper")


func play_idle_down() -> void:
	play_animation("idle-down")


func play_idle_with_slipper() -> void:
	play_animation("idle-w-slipper")


func move_to_position(target_position: Vector2, duration: float, animation_name: String = "", animation_loops: int = 1) -> void:
	if animation_name != "":
		play_animation(animation_name)

	var tween := create_tween()
	tween.tween_property(self, "position", target_position, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	for loop_index in range(max(animation_loops, 1) - 1):
		if animated_sprite:
			await animated_sprite.animation_finished
			play_animation(animation_name)

	await tween.finished


func play_animation_and_wait(animation_name: String) -> void:
	if animated_sprite == null:
		return

	if animated_sprite.sprite_frames == null or not animated_sprite.sprite_frames.has_animation(animation_name):
		return

	play_animation(animation_name)

	if animated_sprite.animation == animation_name:
		await animated_sprite.animation_finished


func _on_animation_finished() -> void:
	if animated_sprite and animated_sprite.animation == "throw":
		play_idle_with_slipper()
