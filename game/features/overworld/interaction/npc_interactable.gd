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
				_: print("Mama: Nagluluto pa ako.")
					
		NpcType.KIKO:
			match state:
				GameManager.StoryState.DAY1_ESKINITA: Dialogic.start("act1_eskinita")
				GameManager.StoryState.DAY1_TUMBANG_TUTORIAL: Dialogic.start("tutorial_tumbang")
				GameManager.StoryState.DAY2_PATINTERO_TUTORIAL: Dialogic.start("tutorial_patintero")
				GameManager.StoryState.DAY3_LUKSONG_TUTORIAL: Dialogic.start("tutorial_luksong")
				_: print("Kiko: Lods! Laro tayo sa Court!")
				
		NpcType.BOY_TSINELAS:
			match state:
				GameManager.StoryState.DAY1_BOSS: Dialogic.start("act1_pre_game")
				_: print("Boy Tsinelas: Bumalik ka pag handa ka na.")
					
		NpcType.KAPITANA_KAT:
			if state == GameManager.StoryState.DAY2_BOSS: Dialogic.start("act2_pre_game")
					
		NpcType.KUYA_TALON:
			if state == GameManager.StoryState.DAY3_BOSS: Dialogic.start("act3_pre_game")
					
		NpcType.COURT_BOARD:
			# Placeholder for the Court Board UI Menu
			print("Opening Court Board...")
