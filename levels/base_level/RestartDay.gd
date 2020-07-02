extends Button

signal restart_button_pressed

func _pressed():
	emit_signal("restart_button_pressed")
