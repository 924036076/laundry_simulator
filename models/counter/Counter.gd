extends "res://models/laundry_holder/LaundryHolder.gd"

func _ready():
	._ready()
	offset = Vector2(-5, -25)

func disallowed_action():
	$AnimationPlayer.play("shake")

func get_jump_launch_position():
	return $JumpLaunch.global_position

func get_sleep_position():
	return $SleepLocation.global_position
	
func cat_shedding():
	interactable = false
	if laundry:
		laundry.hairify()

func _on_Interactable_body_entered(body):
	if body.get_name() == "Cat":
		cat_in_range = true
		return
	._on_Interactable_body_entered(body)
			
func _on_Interactable_body_exited(body):
	if body.get_name() == "Cat":
		cat_in_range = false
		interactable = true
		return
	._on_Interactable_body_exited(body)
