extends CharacterBody3D

@onready var anim_sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	anim_sprite.play("idle")
