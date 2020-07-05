extends Area2D

var points := 3

func _ready():
	$Timer.start()

func _on_Timer_timeout():
	EventHub.emit_signal("patience_cloud", self, points)
