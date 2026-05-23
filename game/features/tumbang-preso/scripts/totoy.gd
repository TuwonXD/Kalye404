extends CharacterBody3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _ready() -> void:
	if animated_sprite_3d and animated_sprite_3d.sprite_frames and animated_sprite_3d.sprite_frames.has_animation("throw"):
		animated_sprite_3d.sprite_frames.set_animation_loop("throw", false)
	# if animated_sprite_3d and not animated_sprite_3d.animation_finished.is_connected(_on_animation_finished):
	#	animated_sprite_3d.animation_finished.connect(_on_animation_finished)


func play_animation(animation_name: String) -> void:
	if animated_sprite_3d == null:
		return

	if animated_sprite_3d.animation == animation_name and animated_sprite_3d.is_playing():
		return

	if animated_sprite_3d.sprite_frames and animated_sprite_3d.sprite_frames.has_animation(animation_name):
		animated_sprite_3d.play(animation_name)


func play_throw() -> void:
	play_animation("throw")


func play_idle() -> void:
	play_animation("idle-down")


func play_idle_with_slipper() -> void:
	play_animation("idle-with-slipper")


# func _on_animation_finished() -> void:
#	if animated_sprite_3d and animated_sprite_3d.animation == "throw":
#		play_idle_with_slipper()


# func _physics_process(delta: float) -> void:
#	# Add the gravity.
#	if not is_on_floor():
#		velocity += get_gravity() * delta
#
#	# Handle jump.
#	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
#		velocity.y = JUMP_VELOCITY
#
#	# Get the input direction and handle the movement/deceleration.
#	# As good practice, you should replace UI actions with custom gameplay actions.
#	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
#	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
#	if direction:
#		velocity.x = direction.x * SPEED
#		velocity.z = direction.z * SPEED
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#		velocity.z = move_toward(velocity.z, 0, SPEED)
#
#	move_and_slide()
