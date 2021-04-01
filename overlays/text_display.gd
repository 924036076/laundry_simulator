extends CanvasLayer
var speed = 20.0 # per second



func _ready():
	EventHub.connect("interactable_broadcasted", self, "_on_interactable_broadcasted")
	$Label.visible = false


func _on_interactable_broadcasted(message):
	$Timer.stop()
	$Label.visible_characters = 0
	$Label.visible = true
	$Label.text = message
	var length = message.length()
	var duration = length / speed
	$Tween.interpolate_property($Label, "visible_characters", 0, length, duration, Tween.EASE_IN, Tween.TRANS_LINEAR)
	$Tween.start()


func _on_Tween_tween_all_completed():
	$Timer.start()


func _on_Timer_timeout():
	$Label.visible = false
