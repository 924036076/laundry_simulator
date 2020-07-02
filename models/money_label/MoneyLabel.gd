extends Node2D

var good = Color(.01, .61, .09, 1)
var meh = Color(.81, .43, .15, 1)
var bad = Color(.83, .13, .04, 1)

func display(message : String, percent : float):
	var color : Color
	if percent <= 0.5:
		color = bad
	elif percent <= 0.75:
		color = meh
	else:
		color = good
	$Label.add_color_override("font_color", color)
	$Label.text = message
	$AnimationPlayer.play("show_self")

func _on_animation_finished(anim_name):
	if anim_name == "show_self":
		queue_free()
