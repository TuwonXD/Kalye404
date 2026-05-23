extends Control

@export var player_power_bar_path: NodePath
@export var enemy_power_bar_path: NodePath

@onready var player_can_row = $PlayerCanRow
@onready var enemy_can_row = $EnemyCanRow
@onready var result_label = $ResultLabel

var player_can_icons: Array[TextureRect] = []
var enemy_can_icons: Array[TextureRect] = []
var result_locked: bool = false

func _ready() -> void:
	player_can_icons = _collect_can_icons(player_can_row)
	enemy_can_icons = _collect_can_icons(enemy_can_row)
	set_player_score(0)
	set_enemy_score(0)
	set_result_text("")
	_bind_player_score_source()
	_bind_enemy_score_source()


func _collect_can_icons(row: Node) -> Array[TextureRect]:
	var icons: Array[TextureRect] = []
	for child in row.get_children():
		if child is TextureRect:
			icons.append(child)
	return icons


func _bind_player_score_source() -> void:
	if player_power_bar_path == NodePath():
		# Try an automatic lookup if the exported path wasn't set
		var auto_node := _find_node_with_signal("player_score_changed")
		if auto_node:
			print("[UI] auto-bound player score source -> ", auto_node)
			player_power_bar_path = auto_node.get_path()
		else:
			return

	var power_bar = get_node_or_null(player_power_bar_path)
	if power_bar:
		if not power_bar.phase_changed.is_connected(_on_phase_changed):
			power_bar.phase_changed.connect(_on_phase_changed)
		if not power_bar.player_score_changed.is_connected(set_player_score):
			power_bar.player_score_changed.connect(set_player_score)
		if not power_bar.player_max_score_reached.is_connected(_on_player_max_score_reached):
			power_bar.player_max_score_reached.connect(_on_player_max_score_reached)
	else:
		print("[UI] failed to bind player score source at path:", player_power_bar_path)


func _bind_enemy_score_source() -> void:
	if enemy_power_bar_path == NodePath():
		# Try an automatic lookup if the exported path wasn't set
		var auto_node := _find_node_with_signal("enemy_score_changed")
		if auto_node:
			print("[UI] auto-bound enemy score source -> ", auto_node)
			enemy_power_bar_path = auto_node.get_path()
		else:
			return

	var power_bar = get_node_or_null(enemy_power_bar_path)
	if power_bar:
		if not power_bar.enemy_score_changed.is_connected(set_enemy_score):
			power_bar.enemy_score_changed.connect(set_enemy_score)
		if not power_bar.enemy_max_score_reached.is_connected(_on_enemy_max_score_reached):
			power_bar.enemy_max_score_reached.connect(_on_enemy_max_score_reached)
	else:
		print("[UI] failed to bind enemy score source at path:", enemy_power_bar_path)


func _find_node_with_signal(signal_name: String) -> Node:
	# Recursively search the scene tree for a node that declares the given signal.
	var root = get_tree().get_root()
	return _find_node_with_signal_recursive(root, signal_name)


func _find_node_with_signal_recursive(node: Node, signal_name: String) -> Node:
	if node.has_signal(signal_name):
		return node
	for child in node.get_children():
		if child is Node:
			var found = _find_node_with_signal_recursive(child, signal_name)
			if found:
				return found
	return null


func _set_can_row_score(can_icons: Array[TextureRect], score: int) -> void:
	for i in range(can_icons.size()):
		can_icons[i].visible = i < score


func set_player_score(score: int) -> void:
	_set_can_row_score(player_can_icons, score)


func set_enemy_score(score: int) -> void:
	_set_can_row_score(enemy_can_icons, score)


func set_result_text(text: String) -> void:
	result_label.text = text
	result_label.visible = not text.is_empty()


func _declare_result(text: String) -> void:
	if result_locked:
		return

	result_locked = true
	set_result_text(text)


func _on_player_max_score_reached(score: int) -> void:
	_declare_result("You win")


func _on_enemy_max_score_reached(score: int) -> void:
	_declare_result("Game over")


func _on_phase_changed(text: String) -> void:
	if result_locked:
		return

	set_result_text(text)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
