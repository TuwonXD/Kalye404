extends Area3D
class_name NPCInteractable

enum NpcType { MAMA, KIKO, BOY_TSINELAS, KAPITANA_KAT, KUYA_TALON, COURT_BOARD }
@export var npc_type: NpcType

signal focused(is_focused)

# Returns true if this NPC has something to say at the current story state
func has_dialogue() -> bool:
	return true

func interact():
	if not has_dialogue():
		return
		
	var state = GameManager.current_story_state
	print("Interacted with NPC Type: ", npc_type, " at State: ", state)
	
	match npc_type:
		NpcType.MAMA:
			match state:
				GameManager.StoryState.DAY1_INTRO: Dialogic.start("act1_intro")
				GameManager.StoryState.DAY1_OUTRO: Dialogic.start("act1_outro")
				GameManager.StoryState.DAY2_INTRO: Dialogic.start("act2_intro")
				GameManager.StoryState.DAY2_OUTRO: Dialogic.start("act2_outro")
				GameManager.StoryState.DAY3_INTRO: Dialogic.start("act3_intro")
				GameManager.StoryState.EPILOGUE: Dialogic.start("epilogue")
				GameManager.StoryState.FINISHED: Dialogic.start("mama_default")
				_: Dialogic.start("mama_default")
					
		NpcType.KIKO:
			match state:
				GameManager.StoryState.DAY1_ESKINITA: Dialogic.start("eskinita_intro")
				GameManager.StoryState.DAY1_TUMBANG_TUTORIAL: Dialogic.start("tutorial_tumbang")
				GameManager.StoryState.DAY2_SIMBAHAN: Dialogic.start("simbahan_intro")
				GameManager.StoryState.DAY2_PATINTERO_TUTORIAL: Dialogic.start("tutorial_patintero")
				GameManager.StoryState.DAY3_LUKSONG_TUTORIAL: Dialogic.start("tutorial_luksong")
				_: Dialogic.start("kiko_default")
				
		NpcType.BOY_TSINELAS:
			if GameManager.game_progress.get("tumbang", 0) >= 4:
				Dialogic.start("tsinelas_champion")
			else:
				Dialogic.start("tsinelas_default")
					
		NpcType.KAPITANA_KAT:
			if GameManager.game_progress.get("patintero", 0) >= 4:
				Dialogic.start("kapitana_champion")
			else:
				Dialogic.start("kapitana_default")
					
		NpcType.KUYA_TALON:
			if GameManager.game_progress.get("luksong", 0) >= 4:
				Dialogic.start("talon_champion")
			else:
				Dialogic.start("talon_default")
					
		NpcType.COURT_BOARD:
			# Placeholder for the Court Board UI Menu
			print("Opening Court Board...")
