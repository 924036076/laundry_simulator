extends TextureButton
class_name RestartDay


func _pressed():
	EventHub.emit_signal("restart")
