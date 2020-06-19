extends "res://models/washer/Washer.gd"

func can_run() -> bool:
	return laundry.can_dry()

func _change_laundry_state():
	laundry.dry()
