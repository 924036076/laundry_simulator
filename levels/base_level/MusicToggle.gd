extends TextureButton

var music : int

func _ready():
	music = AudioServer.get_bus_index("music")

func _toggled(button_pressed):
	if button_pressed:
		AudioServer.set_bus_mute(music, true)
	else:
		AudioServer.set_bus_mute(music, false)
