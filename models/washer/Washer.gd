extends "res://models/interactable/Interactable.gd"
	
func _ready():
	._ready()
	offset = Vector2(0,5)
	
func load_laundry(laundry_in):
	.load_laundry(laundry_in)
	laundry.position = offset
	if laundry.can_wash():
		$AnimationPlayer.play("running")
		laundry.visible = false
		interactable = false
		laundry.wash()
		$Timer.start()
		yield($Timer, "timeout")

func _finish_load():
	$AnimationPlayer.play("idle")
	laundry.visible = true
	interactable = true
	
func reset():
	.reset()
	$AnimationPlayer.play("idle")
	$Timer.stop()
	interactable = true
