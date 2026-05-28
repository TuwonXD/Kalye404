extends Control

@onready var bg = $BG
@onready var green_zone = $GreenZone
@onready var needle = $Needle

var needle_speed: float = 200.0
var needle_direction: float = 1.0
var is_active: bool = false

func _process(delta: float) -> void:
	if not is_active:
		return
	
	# Move needle back and forth
	needle.position.x += needle_speed * needle_direction * delta
	
	# Bounce off edges
	if needle.position.x >= bg.size.x - needle.size.x:
		needle_direction = -1.0
	elif needle.position.x <= 0:
		needle_direction = 1.0

func activate(speed: float, zone_width: float = 60.0) -> void:
	is_active = true
	needle_speed = speed
	needle.position.x = 0
	needle_direction = 1.0
	green_zone.size.x = zone_width
	green_zone.position.x = (bg.size.x - zone_width) / 2.0

func deactivate() -> void:
	is_active = false

func is_in_green_zone() -> bool:
	var needle_center = needle.position.x + needle.size.x / 2.0
	var green_start = green_zone.position.x
	var green_end = green_zone.position.x + green_zone.size.x
	return needle_center >= green_start and needle_center <= green_end
