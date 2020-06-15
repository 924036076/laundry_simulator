extends Node2D

var good = Color(94,250,30)
var meh = Color(250,180,30)
var bad = Color(250,56,30)

func display(message : String, percent : float):
	var modulate : Color
	if percent < 0.5:
		modulate = bad
	elif percent < 0.7:
		modulate = meh
	else:
		modulate = good
	
	$Label.modulate = modulate
	$Label.visible = true
	#$AnimationPlayer.play("New Anim")
	#print("playing!")
	print(message)

