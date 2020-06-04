extends "res://models/interactable/Interactable.gd"

func _ready():
	._ready()
	offset = Vector2(0,5)

func load_laundry(laundry_in):
	.load_laundry(laundry_in)
	laundry.position = offset
	if laundry.can_dry():
		$AnimationPlayer.play("running")
		laundry.visible = false
		laundry_available = false
		laundry.dry()
		$Timer.start()
		yield($Timer, "timeout")

func _finish_load():
	$AnimationPlayer.play("idle")
	laundry.visible = true
	laundry_available = true
