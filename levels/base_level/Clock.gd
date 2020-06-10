extends Node

var hours : int = 7
var minutes : int = 0
var CLOSING_HOUR : int = 19

signal day_over

func _ready():
	update_ui()


func _on_MinuteTimer_timeout():
	minutes += 10
	if minutes >= 60:
		minutes = 0
		hours += 1
		if hours >= CLOSING_HOUR:
			emit_signal("day_over")
	update_ui()
	
func update_ui():
	var time : String = "new text!"
	time = str(hours) + ":" + str(minutes)
	if minutes == 0:
		time = time + "0"
	$RichTextLabel.text = time
