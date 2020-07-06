extends TextureButton
class_name SoundToggle

var soundfx : int

func _ready():
	soundfx = AudioServer.get_bus_index("soundfx")

func _toggled(button_pressed):
	if button_pressed:
		AudioServer.set_bus_mute(soundfx, true)
	else:
		AudioServer.set_bus_mute(soundfx, false)
