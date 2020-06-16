extends Node2D

var good = Color(.01, .61, .09, 1)
var meh = Color(.81, .43, .15, 1)
var bad = Color(.83, .13, .04, 1)

func _ready():
	$AnimationPlayer.play("static")

func display(message : String, percent : float):
	var color : Color
	if percent <= 0.5:
		color = bad
		print("less than 0.5")
	elif percent <= 0.75:
		color = meh
		print("less than 0.75")
	else:
		color = good
		print("is okay!")
	print(percent)
	$Label.add_color_override("font_color", color)

	$Label.visible = true
	$Label.text = message
	$AnimationPlayer.play("New Anim")
	print(message)

