extends Area3D

@export var trigger_state: GameManager.StoryState
@export var timeline_to_play: String

func _ready():
	body_entered.connect(_on_body_entered)
	print("Cutscene Trigger Ready! Waiting for State: ", trigger_state, " to play: ", timeline_to_play)

func _on_body_entered(body):
	print("Something entered the trigger: ", body.name)
	
	if body.is_in_group("Player"):
		print("It is the Player! Current State is: ", GameManager.current_story_state)
		if GameManager.current_story_state == trigger_state:
			print("State matches! Playing cutscene...")
			Dialogic.start(timeline_to_play)
			queue_free()
		else:
			print("State does not match! Needed: ", trigger_state)
	else:
		print("It is NOT in the 'Player' group!")
