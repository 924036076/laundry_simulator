extends Control
const high_score_prefix := "High Score: $"
const new_high_score_prefix := "New High Score!: $"
const score_prefix := "Your earnings: $"
signal new_game_button_pressed


func set_scores(high_score : int, score : int):
	if score == high_score:
		$EndScore.hide()
		$HighScore.text = new_high_score_prefix + str(high_score)
	else:
		$HighScore.text = high_score_prefix + str(high_score)
		$EndScore.text = score_prefix + str(score)
		$EndScore.show()


func _on_Button_pressed():
	emit_signal("new_game_button_pressed")
