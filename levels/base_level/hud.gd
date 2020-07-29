extends CanvasLayer
class_name HUD

signal new_game
const game_over_msg := "Day End"
const new_game_button := "Restart"
const instructions := "Mouse click to move/interact"
const daily_earnings_label := "Daily Earnings: $"
const high_score_label := "High score: $"

func _ready():
	show_overlay(0)
	format_high_score(Global.get_high_score())
	
func show_overlay(score: int):
	$Sprite.visible = true
	$Button.visible = true
	
	if score != 0:
		show_game_over(score)
		check_high_score(score)
	else: 
		$Score.text = instructions
		format_high_score(Global.get_high_score())
		
	$Score.visible = true
	$Title.visible = true

func check_high_score(score: int) -> void:
	if score > Global.get_high_score():
		Global.save(score)
		format_high_score(score)

func format_high_score(score : int) -> void:
	$HighScore.text = high_score_label + str(score)
	if score:
		$HighScore.visible = true
	else:
		$HighScore.visible = false
	
func _on_new_high_score() -> void:
	pass
	
func show_game_over(score : int) -> void:
	$Score.text = daily_earnings_label + str(score)
	$Title.text = game_over_msg
	$Button.text = new_game_button		

func hide_overlay():
	$Sprite.visible = false
	$Title.visible = false
	$Button.visible = false
	$Score.visible = false
	$HighScore.visible = false

func _on_Button_pressed():
	emit_signal("new_game")
	$AudioStreamPlayer.play()
