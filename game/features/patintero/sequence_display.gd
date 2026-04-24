class_name SequenceDisplay
extends HBoxContainer
## Manages the Observation Phase UI.
## Receives a sequence of directions, animates the sequential-then-hold reveal,
## then hides all arrows and emits [signal display_finished].
##
## Attach to: UI/UIRoot/SequenceDisplay (HBoxContainer)

## Emitted when the full observation phase is complete (reveal + hold both done).
## The state machine listens to this to transition to Execution.
signal display_finished

## Maps direction strings to display symbols.
## Replace with TextureRect + arrow icons in Session E art pass.
const DIRECTION_SYMBOLS: Dictionary = {
	"up": "↑",
	"down": "↓",
	"left": "←",
	"right": "→"
}

## Runs the full observation phase for the given sequence.
## [param sequence]: Array[String] of direction strings (e.g., ["up", "left", "down"])
## [param reveal_time]: Seconds per arrow during the sequential reveal.
## [param hold_time]: Seconds all arrows stay visible together after the reveal.
func show_sequence(sequence: Array[String], reveal_time: float, hold_time: float) -> void:
	_clear()
	visible = true

	# Build all arrow labels but start them invisible.
	var labels: Array[Label] = []
	for direction in sequence:
		var label := Label.new()
		label.text = DIRECTION_SYMBOLS.get(direction, "?")
		label.add_theme_font_size_override("font_size", 48)
		label.modulate.a = 0.0  # Start invisible.
		add_child(label)
		labels.append(label)

	# Sequential reveal: fade and scale each arrow in one at a time.
	for label in labels:
		label.scale = Vector2.ZERO
		# Center the pivot so it scales from the middle
		label.pivot_offset = Vector2(24, 40) # Rough center of the text
		
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(label, "scale", Vector2.ONE, reveal_time * 0.5)
		tween.parallel().tween_property(label, "modulate:a", 1.0, reveal_time * 0.5)
		await tween.finished
		await get_tree().create_timer(reveal_time * 0.5).timeout

	# Hold phase: all arrows are now visible. Wait for hold_time.
	await get_tree().create_timer(hold_time).timeout

	# Hide all arrows instantly.
	_clear()
	display_finished.emit()

## Removes all arrow labels and hides the container.
func _clear() -> void:
	for child in get_children():
		child.queue_free()
	visible = false
