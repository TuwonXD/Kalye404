extends Node2D

var enemy_accuracy: int = 0

@onready var power_bar = $PowerBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# _apply_enemy_accuracy(enemy_accuracy)
	power_bar.set_zone_ranges(0.1, 0.2)


func setup(accuracy: int) -> void:
	enemy_accuracy = clampi(accuracy, 0, 100)
	if is_node_ready():
		power_bar.set_zone_ranges(0.5, 0.6)
		# _apply_enemy_accuracy(enemy_accuracy)

# func apply_enemy_accuracy(accuracy: int) -> void:
#	enemy_accuracy = 100 - accuracy
#	var enemy_accuracy_float := 100.0 - float(accuracy)

#	var halfOfOrange := (enemy_accuracy_float / 2.0) / 2.0
	
#	var green_zone_end := (enemy_accuracy_float - halfOfOrange) / 100
#	var orange_zone_end := (green_zone_end * 100 + (halfOfOrange * 2)) / 100

#	green_zone_end = clampf(green_zone_end, 0.0, 1.0)
#	orange_zone_end = clampf(orange_zone_end, green_zone_end, 1.0)
	
#	if is_equal_approx(green_zone_end, 0.0):
#		green_zone_end = 0.05
#		orange_zone_end = 0.1

func _apply_enemy_accuracy(accuracy: int) -> void:
	var clamped_accuracy := clampi(accuracy, 0, 100)
	var green_zone_end := clampf(float(clamped_accuracy) * 0.0075, 0.0, 1.0)
	var orange_zone_end := clampf(green_zone_end + 0.05, green_zone_end, 1.0)

	power_bar.set_zone_ranges(green_zone_end, orange_zone_end)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
