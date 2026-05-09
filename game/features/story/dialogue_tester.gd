extends Node2D

func _ready():
	# This tells Dialogic to start your prologue timeline the moment the scene loads!
	# (Make sure "prologue_intro" matches the exact name of your .dtl file)
	Dialogic.start("prologue_intro")
