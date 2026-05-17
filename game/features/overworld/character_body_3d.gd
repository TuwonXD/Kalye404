extends CharacterBody3D

const WALKSPEED = 1.0
const RUNSPEED = 2.0
const JUMP_VELOCITY = 10.0
var current_speed: float = WALKSPEED

@onready var animated_sprite = $AnimatedSprite3D
@onready var raycast = $RayCast3D
@onready var camera_pivot = $CameraPivot

var camera_angle: float = 0.0
const CAM_SNAP: float = 90.0
var is_rotating: bool = false
var last_direction := "down"

# This is the base offset that shifts whenever the camera rotates
var direction_offset: float = 0.0

func _physics_process(delta: float) -> void:
	handle_sprint()

	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- CAMERA ROTATION INPUT ---
	if Input.is_action_just_pressed("rotate_cam") and not is_rotating:
		var target_angle = get_camera_angle_for_direction(last_direction)
		if target_angle != camera_angle:
			# Update the offset so future lookups shift accordingly
			direction_offset += target_angle - camera_angle
			camera_angle = target_angle
			is_rotating = true
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(camera_pivot, "rotation_degrees:y", camera_angle, 0.3)
			tween.tween_callback(func(): is_rotating = false)

	# --- MOVEMENT ---
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := Vector3.ZERO

	if input_dir != Vector2.ZERO:
		var cam_forward = -camera_pivot.global_transform.basis.z
		var cam_right = camera_pivot.global_transform.basis.x
		cam_forward.y = 0
		cam_right.y = 0
		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()
		direction = (cam_right * input_dir.x + cam_forward * -input_dir.y).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

		animated_sprite.flip_h = false

		if input_dir.x > 0:
			animated_sprite.play("walk right")
			last_direction = "right"
		elif input_dir.x < 0:
			animated_sprite.play("walk left")
			last_direction = "left"
		elif input_dir.y < 0:
			animated_sprite.play("walk up")
			last_direction = "up"
		elif input_dir.y > 0:
			animated_sprite.play("walk down")
			last_direction = "down"
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

		match last_direction:
			"right":      animated_sprite.play("Idle right")
			"left":       animated_sprite.play("Idle left")
			"up":         animated_sprite.play("Idle up")
			"down":       animated_sprite.play("Idle down")

	move_and_slide()

func get_camera_angle_for_direction(dir: String) -> float:
	# Base angles for each direction
	var base_angles = {
		"up":         0.0,
		"right":     -90.0,
		"down":       180.0,
		"left":       90.0,
	}
	# Shift the base angle by however much the camera has already rotated
	return base_angles.get(dir, 0.0) + direction_offset

func handle_sprint():
	if Input.is_action_pressed("sprint"):
		current_speed = RUNSPEED
	else:
		current_speed = WALKSPEED
