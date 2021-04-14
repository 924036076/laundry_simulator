extends Node

var hours : int
var minutes : int

const STARTING_HOUR := 7
const STARTING_MINUTE := 0
const CLOSING_HOUR := 20 #20

signal new_hour
signal almost_closing


func _ready():
	reset()
	EventHub.connect("day_over", self, "_on_day_over")
	EventHub.connect("game_over", self, "_on_game_over")
	EventHub.connect("new_day", self, "_on_new_day")
	EventHub.connect("new_game", self, "_on_new_day")


func _on_MinuteTimer_timeout():
	minutes += 10
	if minutes >= 60:
		minutes = 0
		hours += 1
		emit_signal("new_hour", hours)
		if hours >= CLOSING_HOUR - 2:
			emit_signal("almost_closing")
		if hours >= CLOSING_HOUR:
			print("day over signal!")
			EventHub.emit_signal("day_over")
	update_ui()


func update_ui():
	var time := "new text!"
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


func _on_day_over():
	stop()


func _on_game_over():
	stop()


func _on_new_day():
	print("new day!")
	restart()

