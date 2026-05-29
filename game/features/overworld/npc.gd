extends CharacterBody3D

@export var speed: float = 1.0
@export var wander_radius: float = 10.0  # How far the NPC can roam
@export var wait_time_min: float = 1.0   # Min pause before picking new target
@export var wait_time_max: float = 3.0   # Max pause

var nav_agent: NavigationAgent3D
var start_position: Vector3
var is_waiting: bool = false

func _ready():
	nav_agent = $NavigationAgent3D
	start_position = global_position
	_pick_new_target()

func _physics_process(delta):
	if is_waiting:
		return

	if nav_agent.is_navigation_finished():
		_start_waiting()
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()

	velocity = direction * speed
	move_and_slide()

	# Optional: rotate NPC to face movement direction
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)

func _pick_new_target():
	is_waiting = false
	# Pick a random point within wander_radius
	var random_offset = Vector3(
		randf_range(-wander_radius, wander_radius),
		0,
		randf_range(-wander_radius, wander_radius)
	)
	nav_agent.target_position = start_position + random_offset

func _start_waiting():
	is_waiting = true
	var wait_duration = randf_range(wait_time_min, wait_time_max)
	await get_tree().create_timer(wait_duration).timeout
	_pick_new_target()
