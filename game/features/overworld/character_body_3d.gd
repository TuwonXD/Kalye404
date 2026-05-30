extends CharacterBody3D

const WALKSPEED = 0.7
const RUNSPEED = 1.5
var current_speed: float = WALKSPEED

@onready var animated_sprite = $AnimatedSprite3D
@onready var raycast = $RayCast3D
@onready var camera_pivot = $CameraPivot

var camera_angle: float = 0.0
const CAM_SNAP: float = 90.0
var is_rotating: bool = false
var last_direction := "down"
var direction_offset: float = 0.0

func _ready() -> void:
	if GameManager.player_position != Vector3.ZERO:
		global_position = GameManager.player_position
	
	# Listen for story state changes to teleport player at the start of a new day
	GameManager.story_state_changed.connect(_on_story_state_changed)

func _on_story_state_changed(state: GameManager.StoryState) -> void:
	if state == GameManager.StoryState.DAY1_INTRO or state == GameManager.StoryState.DAY2_INTRO or state == GameManager.StoryState.DAY3_INTRO:
		# Reset to the starting position requested by user
		global_position = Vector3(8.663, 0.401, -6.381)
		GameManager.player_position = global_position

func _physics_process(delta: float) -> void:
	# Keep GameManager updated with our exact position so we don't lose it if scenes change
	GameManager.player_position = global_position
	
	# Prevent moving while dialogue is active
	if GameManager.is_dialogue_active:
		velocity.x = 0
		velocity.z = 0
		animated_sprite.stop()
		move_and_slide()
		return
	
	handle_sprint()
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# --- CAMERA ROTATION INPUT ---
	if Input.is_action_just_pressed("rotate_cam") and not is_rotating:
		var target_angle = get_camera_angle_for_direction(last_direction)
		
		if target_angle != camera_angle:
			direction_offset += target_angle - camera_angle
			camera_angle = target_angle
			is_rotating = true
			last_direction = "up"
			var is_moving = velocity.x != 0 or velocity.z != 0
			var is_sprinting = Input.is_action_pressed("sprint")
			
			if is_moving:
				animated_sprite.play("run up" if is_sprinting else "walk up")
			else:
				animated_sprite.play("Idle up")
				
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(camera_pivot, "rotation_degrees:y", camera_angle, 0.3)
			tween.tween_callback(func(): is_rotating = false)

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
	
	var is_sprinting = Input.is_action_pressed("sprint")
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		animated_sprite.flip_h = false
		
		if not is_rotating:
			if input_dir.x > 0:
				last_direction = "right"
				animated_sprite.play("run right" if is_sprinting else "walk right")
			elif input_dir.x < 0:
				last_direction = "left"
				animated_sprite.play("run left" if is_sprinting else "walk left")
			elif input_dir.y < 0:
				last_direction = "up"
				animated_sprite.play("run up" if is_sprinting else "walk up")
			elif input_dir.y > 0:
				last_direction = "down"
				animated_sprite.play("run down" if is_sprinting else "walk down")
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		if not is_rotating:
			match last_direction:
				"right": animated_sprite.play("Idle right")
				"left":  animated_sprite.play("Idle left")
				"up":    animated_sprite.play("Idle up")
				"down":  animated_sprite.play("Idle down")
	move_and_slide()

func get_camera_angle_for_direction(dir: String) -> float:
	var base_angles = {
		"up":    0.0,
		"right": -90.0,
		"down":  180.0,
		"left":  90.0,
	}
	return base_angles.get(dir, 0.0) + direction_offset

func handle_sprint():
	if Input.is_action_pressed("sprint"):
		current_speed = RUNSPEED
	else:
		current_speed = WALKSPEED
