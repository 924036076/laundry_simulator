extends "res://models/laundry_holder/LaundryHolder.gd"

func _ready() -> void:
	._ready()
	offset = Vector2(-5, -25)

func disallowed_action() -> void:
	$AnimationPlayer.play("shake")

func get_jump_launch_position() -> Vector2:
	return $JumpLaunch.global_position

func get_sleep_position() -> Vector2:
	return $SleepLocation.global_position
	
func cat_shedding() -> void:
	interactable = false

func _on_Interactable_body_exited(body : PhysicsBody2D) -> void:
	# Cat only sleeps on counters 
	if body.get_name() == "Cat":
		interactable = true

