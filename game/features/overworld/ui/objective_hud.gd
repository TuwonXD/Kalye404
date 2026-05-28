extends CanvasLayer

@onready var label = $MarginContainer/PanelContainer/MarginContainer/Label

func _ready():
	# Wait for GameManager to be ready just in case
	await get_tree().process_frame
	
	if GameManager:
		GameManager.story_state_changed.connect(_on_story_state_changed)
		# Initialize with current state
		_on_story_state_changed(GameManager.current_story_state)
	else:
		push_error("GameManager Autoload not found! Make sure you added game_manager.gd to Project Settings -> AutoLoad.")
		
	# Hide during dialogue / cutscenes
	if Dialogic:
		Dialogic.timeline_started.connect(func(): visible = false)
		Dialogic.timeline_ended.connect(func(): visible = true)

func _on_story_state_changed(state: int):
	var task_text = "Task: "
	
	match state:
		GameManager.StoryState.DAY1_INTRO:
			task_text += "Pumunta sa tindahan at bumili ng suka."
		GameManager.StoryState.DAY1_ESKINITA:
			task_text += "Pumunta sa tindahan at bumili ng suka."
		GameManager.StoryState.DAY1_TUMBANG_TUTORIAL:
			task_text += "Sundan si Kiko sa Covered Court at kausapin siya."
		GameManager.StoryState.DAY1_TUMBANG_GRIND:
			task_text += "Sanayin ang Tumbang Preso sa Court Board (Talunin ang Champion)."
		GameManager.StoryState.DAY1_BOSS:
			task_text += "Hamunin si Boy Tsinelas sa Covered Court."
		GameManager.StoryState.DAY1_OUTRO:
			task_text += "Umuwi sa bahay at ibigay ang suka kay Mama."
		GameManager.StoryState.DAY2_INTRO:
			task_text += "Pumunta sa Simbahan at bumili ng pandesal."
		GameManager.StoryState.DAY2_PATINTERO_TUTORIAL:
			task_text += "Kausapin si Kiko sa Covered Court tungkol sa Patintero."
		GameManager.StoryState.DAY2_PATINTERO_GRIND:
			task_text += "Sanayin ang Patintero sa Court Board (Talunin ang Champion)."
		GameManager.StoryState.DAY2_BOSS:
			task_text += "Hamunin si Kapitana Kat sa Covered Court."
		GameManager.StoryState.DAY2_OUTRO:
			task_text += "Umuwi sa bahay at ibigay ang pandesal kay Mama."
		GameManager.StoryState.DAY3_INTRO:
			task_text += "Isauli ang tupperware kay Aling Nena."
		GameManager.StoryState.DAY3_LUKSONG_TUTORIAL:
			task_text += "Kausapin si Kiko sa Covered Court tungkol sa Luksong Baka."
		GameManager.StoryState.DAY3_LUKSONG_GRIND:
			task_text += "Sanayin ang Luksong Baka sa Court Board (Talunin ang Champion)."
		GameManager.StoryState.DAY3_BOSS:
			task_text += "Hamunin si Kuya Talon sa Covered Court."
		GameManager.StoryState.EPILOGUE:
			task_text += "Umuwi sa bahay."
		_:
			task_text += "Mag-explore."
			
	label.text = task_text
