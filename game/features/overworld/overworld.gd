extends Node3D  # ← This line is required!

@export var npc_scene: PackedScene
@export var npc_count: int = 5

func _ready():
	# Fade in from the GameManager's initial black screen
	if GameManager._fade_rect:
		var tween = create_tween()
		tween.tween_property(GameManager._fade_rect, "modulate:a", 0.0, 1.0)
		
		# Wait for GameManager to finish its fade-in animation before starting dialogue
		# This prevents the user from accidentally clicking and skipping dialogue while the screen is black!
		await get_tree().create_timer(0.6).timeout
		
	if GameManager.pending_dialogue != "":
		Dialogic.start(GameManager.pending_dialogue)
		GameManager.pending_dialogue = ""
	elif GameManager.current_story_state == GameManager.StoryState.DAY1_INTRO:
		Dialogic.start("act1_intro")
	elif GameManager.current_story_state == GameManager.StoryState.DAY2_INTRO:
		Dialogic.start("act2_intro")
	elif GameManager.current_story_state == GameManager.StoryState.DAY3_INTRO:
		Dialogic.start("act3_intro")
#	for i in npc_count:
#		var npc = npc_scene.instantiate()
#		add_child(npc)
#		npc.global_position = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
