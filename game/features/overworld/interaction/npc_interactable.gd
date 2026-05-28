extends Area3D
class_name NPCInteractable

enum NpcType { MAMA, KIKO, BOY_TSINELAS, KAPITANA_KAT, KUYA_TALON, COURT_BOARD }
@export var npc_type: NpcType

signal focused(is_focused)

# Returns true if this NPC has something to say at the current story state
func has_dialogue() -> bool:
	var state = GameManager.current_story_state
	match npc_type:
		NpcType.MAMA:
			return state in [
				GameManager.StoryState.DAY1_INTRO,
				GameManager.StoryState.DAY1_OUTRO,
				GameManager.StoryState.DAY2_INTRO,
				GameManager.StoryState.DAY2_OUTRO,
				GameManager.StoryState.DAY3_INTRO,
				GameManager.StoryState.EPILOGUE
			]
		NpcType.KIKO:
			return state in [
				GameManager.StoryState.DAY1_TUMBANG_TUTORIAL,
				GameManager.StoryState.DAY2_PATINTERO_TUTORIAL,
				GameManager.StoryState.DAY3_LUKSONG_TUTORIAL
			]
		NpcType.BOY_TSINELAS:
			return state == GameManager.StoryState.DAY1_BOSS
		NpcType.KAPITANA_KAT:
			return state == GameManager.StoryState.DAY2_BOSS
		NpcType.KUYA_TALON:
			return state == GameManager.StoryState.DAY3_BOSS
		NpcType.COURT_BOARD:
			return state in [
				GameManager.StoryState.DAY1_TUMBANG_GRIND,
				GameManager.StoryState.DAY2_PATINTERO_GRIND,
				GameManager.StoryState.DAY3_LUKSONG_GRIND
			]
	return false

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
					
		NpcType.KIKO:
			match state:
				GameManager.StoryState.DAY1_ESKINITA: Dialogic.start("act1_eskinita")
				GameManager.StoryState.DAY1_TUMBANG_TUTORIAL: Dialogic.start("tutorial_tumbang")
				GameManager.StoryState.DAY2_PATINTERO_TUTORIAL: Dialogic.start("tutorial_patintero")
				GameManager.StoryState.DAY3_LUKSONG_TUTORIAL: Dialogic.start("tutorial_luksong")
				
		NpcType.BOY_TSINELAS:
			if state == GameManager.StoryState.DAY1_BOSS: Dialogic.start("act1_pre_game")
					
		NpcType.KAPITANA_KAT:
			if state == GameManager.StoryState.DAY2_BOSS: Dialogic.start("act2_pre_game")
					
		NpcType.KUYA_TALON:
			if state == GameManager.StoryState.DAY3_BOSS: Dialogic.start("act3_pre_game")
					
		NpcType.COURT_BOARD:
			# Placeholder for the Court Board UI Menu
			print("Opening Court Board...")
