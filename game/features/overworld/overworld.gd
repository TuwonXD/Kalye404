extends Node3D  # ← This line is required!

@export var npc_scene: PackedScene
@export var npc_count: int = 5

func _ready():
	await get_tree().process_frame
	if GameManager.current_story_state == GameManager.StoryState.DAY1_INTRO:
		Dialogic.start("act1_intro")
#	for i in npc_count:
#		var npc = npc_scene.instantiate()
#		add_child(npc)
#		npc.global_position = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
