extends TextureButton


func _ready():
	EventHub.connect("new_day", self, "_on_new_day")


func _on_PauseToggle_toggled(button_pressed):
	if button_pressed:
		get_tree().paused = true
	else:
		get_tree().paused = false


func _on_new_day():
	pressed = false
