extends CanvasLayer

signal new_game
var game_over_msg = "Day End"
var new_game_button = "Restart"
# Called when the node enters the scene tree for the first time.
func _ready():
	#$Score.visible = false
	show_overlay(null)

func show_overlay(score):
	$Sprite.visible = true
	$Button.visible = true
	
	if score != null:
		$Score.text = str(score)
		$Score.visible = true
		$Title.text = game_over_msg
		$Button.text = new_game_button
		
	$Title.visible = true
	
func hide_overlay():
	$Sprite.visible = false
	$Title.visible = false
	$Button.visible = false
	$Score.visible = false

func _on_Button_pressed():
	emit_signal("new_game")
	$AudioStreamPlayer.play()
