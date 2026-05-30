extends Node3D 
# Can be attached to a StaticBody3D (like an invisible wall) or a MeshInstance3D (like a prop)

@export var unlock_state: GameManager.StoryState

func _ready():
	# Wait a frame to ensure GameManager is fully loaded
	await get_tree().process_frame
	if GameManager:
		GameManager.story_state_changed.connect(_on_state_changed)
		_check_state(GameManager.current_story_state)
	else:
		push_error("StoryBlocker: GameManager Autoload not found.")

func _on_state_changed(new_state: int):
	_check_state(new_state)

func _check_state(state: int):
	# If the current story state is equal to or past the unlock state, remove the blocker
	if state >= unlock_state:
		print("StoryBlocker: Path unlocked! Destroying barrier.")
		queue_free()
