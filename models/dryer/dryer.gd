extends Washer
class_name Dryer

func can_run() -> bool:
	return laundry.can_dry()

func _change_laundry_state() -> void:
	laundry.dry()
	EventHub.emit_signal("laundry_dried")
