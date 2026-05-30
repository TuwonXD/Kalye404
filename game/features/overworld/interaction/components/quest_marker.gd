extends MeshInstance3D

@export var active_states: Array[GameManager.StoryState]

func _ready():
	# Wait a frame to ensure GameManager is ready
	await get_tree().process_frame
	
	GameManager.story_state_changed.connect(_on_story_state_changed)
	
	# Play bobbing animation programmatically
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y + 0.5, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y, 1.0).set_trans(Tween.TRANS_SINE)
	
	# Initial check
	_on_story_state_changed(GameManager.current_story_state)

func _on_story_state_changed(state: int):
	# If this marker's exported states contain the current state, show it!
	visible = state in active_states
