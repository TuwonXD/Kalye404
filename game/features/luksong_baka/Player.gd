extends CharacterBody2D

const GRAVITY = 980.0
const RUN_SPEED = 200.0
const JUMP_FORCE = -600.0
const JUMP_TRIGGER_X = -60.0  # distance from Baka where player stops

@onready var anim_player = $AnimationPlayer

var is_running: bool = false
var is_jumping: bool = false
var start_position: Vector2

func _ready() -> void:
	start_position = global_position

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if is_running:
		velocity.x = RUN_SPEED
		# Check if player reached the trigger point near Baka
		var baka = get_tree().get_first_node_in_group("baka")
		if baka and global_position.x >= baka.global_position.x + JUMP_TRIGGER_X:
			stop_at_baka()

	move_and_slide()

func start_running() -> void:
	is_running = true
	is_jumping = false
	anim_player.play("run")

func stop_at_baka() -> void:
	is_running = false
	velocity.x = 0
	anim_player.play("idle")
	# Notify Main that player has reached the Baka
	get_parent().on_player_reached_baka()

func do_jump() -> void:
	is_jumping = true
	velocity.y = JUMP_FORCE
	velocity.x = RUN_SPEED
	anim_player.play("jump")
	
func do_trip() -> void:
	# Fixed jump height, flies over but faceplants on landing
	is_jumping = true
	velocity.y = -400.0
	velocity.x = RUN_SPEED
	anim_player.play("jump")
	# Wait for peak of jump then switch to fail
	await get_tree().create_timer(0.4).timeout
	anim_player.play("fail")
	# Let gravity bring them down naturally
	await get_tree().create_timer(0.8).timeout
	reset_position()
func reset_position() -> void:
	is_running = false
	is_jumping = false
	global_position = start_position
	velocity = Vector2.ZERO
	anim_player.play("idle")
