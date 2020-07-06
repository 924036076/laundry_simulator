extends RichTextLabel
class_name MoneyLabel

var score : int = 0

func _ready():
	format_score()
	
func reset():
	score = 0
	format_score()

func format_score():
	set_text("$" + str(score))

func _on_Events_score_update(addition : float):
	score += round(addition)
	format_score()