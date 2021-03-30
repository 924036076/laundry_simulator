extends HBoxContainer

export var restart_enabled = false


func _ready():
	if restart_enabled:
		$RestartDay.visible = true
	else:
		$RestartDay.visible = false
