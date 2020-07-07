extends Node2D
class_name PatiencePoint
const addition := Color(.01, .61, .09, 1)
const subtraction := Color(.83, .13, .04, 1)

func set_and_show(percent : int) -> void:
	if percent == 0:
		return
	var operator = "+" if percent > 0 else ""
	$Label.modulate = addition if percent > 0 else subtraction
	$Label.text = operator + str(percent)
	$AnimationPlayer.play("show")

func _on_AnimationPlayer_animation_finished(anim_name : String):
	if anim_name == "show":
		queue_free()
