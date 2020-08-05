extends Control
signal start_button_pressed


func _on_Button_pressed():
	emit_signal("start_button_pressed")
