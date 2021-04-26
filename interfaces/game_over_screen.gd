extends Control
const HIGH_SCORE_PREFIX := "High Score: $%d"
const NEW_HIGH_SCORE_PREFIX := "New High Score!: $%d"
const SCORE_PREFIX := "Your earnings: $%d"
signal new_game_button_pressed


func set_scores(high_score : int, score : int):
  if score == high_score:
    $EndScore.hide()
    $HighScore.text = NEW_HIGH_SCORE_PREFIX % high_score
  else:
    $HighScore.text = HIGH_SCORE_PREFIX % high_score
    $EndScore.text = SCORE_PREFIX % score
    $EndScore.show()


func _on_Button_pressed():
  emit_signal("new_game_button_pressed")
