extends Control

@export var bar_width: float = 50.0
@export var bar_height: float = 400.0

# pixels per second
@export var arrow_speed: float = 200.0


# manipulates the size of the zones

# Zones are expressed as vertical ranges in normalized bar space.
# 0.0 = bottom, 1.0 = top

# green start and end (0-11.25%)
@export var min_zone: Vector2 = Vector2(0.0, 0.1125)  

 # orange (11.25%-26.25%)
@export var mid_zone: Vector2 = Vector2(0.1125, 0.2625) 

 # red (26.25%-100%)
@export var max_zone: Vector2 = Vector2(0.2625, 1.0) 

@onready var arrow = $Arrow
@onready var green_zone = $GreenZone
@onready var orange_zone = $OrangeZone
@onready var red_zone = $RedZone
@onready var background = $Background

# 0.0 to 1.0, bottom to top
var arrow_position: float = 0.0  

# 1 = up, -1 = down
var arrow_direction: float = 1.0  

var is_active: bool = false
var stopped: bool = false
var stopped_position: float = 0.0
var restart_enabled: bool = true

signal power_bar_stopped(position: float, zone: String)


func set_zone_ranges(green_zone_end: float, orange_zone_end: float) -> void:
	min_zone = Vector2(0.0, clampf(green_zone_end, 0.0, 1.0))
	mid_zone = Vector2(min_zone.y, clampf(orange_zone_end, min_zone.y, 1.0))
	max_zone = Vector2(mid_zone.y, 1.0)
	_update_zone_visuals()


func set_arrow_speed(speed: float) -> void:
	arrow_speed = maxf(10.0, speed)


func set_restart_enabled(enabled: bool) -> void:
	restart_enabled = enabled

# Called when the node enters the scene tree for the first time.
func _ready():
	size = Vector2(bar_width, bar_height)
	background.position = Vector2.ZERO
	background.size = Vector2(bar_width, bar_height)

	green_zone.position = Vector2.ZERO
	green_zone.size = Vector2(bar_width, bar_height * (min_zone.y - min_zone.x))

	orange_zone.position = Vector2(0, bar_height * mid_zone.x)
	orange_zone.size = Vector2(bar_width, bar_height * (mid_zone.y - mid_zone.x))

	red_zone.position = Vector2(0, bar_height * max_zone.x)
	red_zone.size = Vector2(bar_width, bar_height * (max_zone.y - max_zone.x))

	arrow.position = Vector2.ZERO
	_update_zone_visuals()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Poll the action each frame so input still works when this Control
	# is placed inside a SubViewport/viewport attached to the camera.
	if Input.is_action_just_pressed("StopArrow"):
		if is_active and not stopped:
			stop()
		elif not is_active and not stopped:
			start()

	if not is_active or stopped:
		return

	var usable_height = get_usable_height()

	arrow_position += arrow_direction * arrow_speed * delta / usable_height

	# Clamp normalized value
	arrow_position = clampf(arrow_position, 0.0, 1.0)

	# Bounce
	if arrow_position == 1.0:
		arrow_direction = -1.0
	elif arrow_position == 0.0:
		arrow_direction = 1.0

	# Convert normalized -> pixels
	arrow.position.y = usable_height * (1.0 - arrow_position)

func _update_zone_visuals():
	green_zone.position = Vector2.ZERO
	green_zone.size = Vector2(bar_width, bar_height * (min_zone.y - min_zone.x))

	orange_zone.position = Vector2(0, bar_height * mid_zone.x)
	orange_zone.size = Vector2(bar_width, bar_height * (mid_zone.y - mid_zone.x))

	red_zone.position = Vector2(0, bar_height * max_zone.x)
	red_zone.size = Vector2(bar_width, bar_height * (max_zone.y - max_zone.x))

func start():
	is_active = true
	stopped = false
	arrow_position = 0.0
	arrow_direction = 1.0
	arrow.position.y = get_usable_height()


func stop():
	if not is_active:
		return

	is_active = false
	stopped = true
	stopped_position = arrow_position

	var zone = get_zone_at_position(stopped_position)
	print("[PowerBar] stop() -> pos=", stopped_position, " zone=", zone)

	power_bar_stopped.emit(stopped_position * 100.0, zone)

	# otherwise, restart the bar after a short delay
	if not restart_enabled:
		return

	await get_tree().create_timer(1).timeout
	start()


func force_stop(zone: String) -> void:
	if not is_active:
		return

	is_active = false
	stopped = true
	stopped_position = arrow_position

	print("[PowerBar] force_stop() -> pos=", stopped_position, " zone=", zone)
	power_bar_stopped.emit(stopped_position * 100.0, zone)

	if not restart_enabled:
		return

	await get_tree().create_timer(1).timeout
	start()


func _input(event):
	if event.is_action_pressed("StopArrow"):
		if is_active and not stopped:
			stop()
		elif not is_active and not stopped:
			start()


func get_zone_at_position(pos: float) -> String:
	var pos_from_top := 1.0 - pos

	if pos_from_top >= min_zone.x and pos_from_top < min_zone.y:
		return "green"
		
	elif pos_from_top >= mid_zone.x and pos_from_top < mid_zone.y:
		return "orange"
		
	elif pos_from_top >= max_zone.x and pos_from_top <= max_zone.y:
		return "red"
		
	return "unknown"

func reset():
	is_active = false
	stopped = false
	arrow_position = 0.0
	arrow_direction = 1.0
	arrow.position.y = bar_height - arrow.size.y

func get_usable_height() -> float:
	return bar_height - arrow.size.y
