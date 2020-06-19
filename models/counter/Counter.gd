extends "res://models/interactable/Interactable.gd"

func disallowed_action():
	$AnimationPlayer.play("shake")
