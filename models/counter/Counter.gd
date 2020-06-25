extends "res://models/interactable/Interactable.gd"

func _ready():
	._ready()
	offset = Vector2(-5, -25)

func disallowed_action():
	$AnimationPlayer.play("shake")
