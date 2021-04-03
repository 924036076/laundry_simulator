extends CanvasLayer
var next_scene


func _ready():
	EventHub.connect("laundromat_purchased", self, "_on_laundromat_purchased")


func _on_laundromat_purchased():
	$AnimationPlayer.play("fade_in_out")
	next_scene = "res://levels/base_level/laundry_scene.tscn"


func switch_scene():
	get_tree().change_scene(next_scene)
