extends Area3D

var interactables_in_range: Array = []
var closest_interactable = null

# Connect this signal to a UI Label to show/hide a "Press E to Talk" prompt
signal prompt_updated(is_visible)

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(_delta):
	if GameManager.is_dialogue_active:
		if closest_interactable != null:
			_set_closest(null)
		return

	# Continuously update which NPC is closest if multiple are in range
	if interactables_in_range.is_empty():
		if closest_interactable != null:
			_set_closest(null)
		return
	
	# Filter to only NPCs that actually have something to say
	var talkable = interactables_in_range.filter(func(npc): return npc.has_method("has_dialogue") and npc.has_dialogue())
	
	if talkable.is_empty():
		if closest_interactable != null:
			_set_closest(null)
		return
		
	var new_closest = talkable[0]
	var min_dist = global_position.distance_squared_to(new_closest.global_position)
	
	for i in range(1, talkable.size()):
		var interactable = talkable[i]
		var dist = global_position.distance_squared_to(interactable.global_position)
		if dist < min_dist:
			min_dist = dist
			new_closest = interactable
			
	if new_closest != closest_interactable:
		_set_closest(new_closest)

func _set_closest(interactable):
	if closest_interactable != null and closest_interactable.has_signal("focused"):
		closest_interactable.emit_signal("focused", false)
		
	closest_interactable = interactable
	
	if closest_interactable != null:
		if closest_interactable.has_signal("focused"):
			closest_interactable.emit_signal("focused", true)
		emit_signal("prompt_updated", true)
	else:
		emit_signal("prompt_updated", false)

func _input(event):
	# Press E (or whatever "interact" is mapped to) to trigger the dialogue
	if event.is_action_pressed("interact") and closest_interactable != null:
		if closest_interactable.has_method("interact"):
			closest_interactable.interact()

func _on_area_entered(area):
	if area.has_method("interact") and not interactables_in_range.has(area):
		interactables_in_range.append(area)

func _on_area_exited(area):
	if interactables_in_range.has(area):
		interactables_in_range.erase(area)
