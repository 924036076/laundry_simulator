extends TextureButton


func _on_PauseToggle_toggled(button_pressed):
	if button_pressed:
		get_tree().paused = true
	else:
		get_tree().paused = false
