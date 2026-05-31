extends Node3D  # ← This line is required!

@export var npc_scene: PackedScene
@export var npc_count: int = 5

func _ready():
	print("[DEBUG-FREEZE] Overworld _ready() called. Deferring dialogue check...")
	call_deferred("_start_pending_dialogue")

func _start_pending_dialogue() -> void:
	print("[DEBUG-FREEZE] _start_pending_dialogue starting. Waiting 0.6s...")
	await get_tree().create_timer(0.6).timeout
	print("[DEBUG-FREEZE] 0.6s wait finished. pending_dialogue = '", GameManager.pending_dialogue, "'")
	
	if GameManager.pending_dialogue != "":
		print("[DEBUG-FREEZE] Calling Dialogic.start(", GameManager.pending_dialogue, ")")
		Dialogic.start(GameManager.pending_dialogue)
		print("[DEBUG-FREEZE] Dialogic.start() returned!")
		GameManager.pending_dialogue = ""
	elif GameManager.current_story_state == GameManager.StoryState.DAY1_INTRO:
		print("[DEBUG-FREEZE] Calling Dialogic.start(act1_intro)")
		Dialogic.start("act1_intro")
	elif GameManager.current_story_state == GameManager.StoryState.DAY2_INTRO:
		print("[DEBUG-FREEZE] Calling Dialogic.start(act2_intro)")
		Dialogic.start("act2_intro")
	elif GameManager.current_story_state == GameManager.StoryState.DAY3_INTRO:
		print("[DEBUG-FREEZE] Calling Dialogic.start(act3_intro)")
		Dialogic.start("act3_intro")
#	for i in npc_count:
#		var npc = npc_scene.instantiate()
#		add_child(npc)
#		npc.global_position = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
