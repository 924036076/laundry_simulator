extends Node

var hours : int
var minutes : int

var STARTING_HOUR : int = 7
var STARTING_MINUTE : int = 0
var CLOSING_HOUR : int = 19

signal new_hour
signal day_over
signal almost_closing

func _ready():
	reset()

func _on_MinuteTimer_timeout():
	minutes += 10
	if minutes >= 60:
		minutes = 0
		hours += 1
		emit_signal("new_hour", hours)
		if hours >= CLOSING_HOUR - 1:
			emit_signal("almost_closing")
		if hours >= CLOSING_HOUR:
			emit_signal("day_over")
	update_ui()
	
func update_ui():
	var time : String = "new text!"
	time = str(hours) + ":" + str(minutes)
	if minutes == 0:
		time = time + "0"
	$RichTextLabel.text = time
	
func start():
	$MinuteTimer.start()	
	
func stop():
	$MinuteTimer.stop()
	
func reset():
	hours = STARTING_HOUR
	minutes = STARTING_MINUTE
	update_ui()
	
func restart():
	reset()
	start()

