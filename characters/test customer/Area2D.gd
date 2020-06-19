extends "res://models/interactable/Interactable.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal released
signal returned

# Called when the node enters the scene tree for the first time.
func _ready():
	print("customer area2d ready and reporting for duty!")
	offset = Vector2(0,12)
	can_receive = false
	
func _calculate_radius():
	return $CollisionShape2D.shape.radius
	
func set_target(boolean):
	is_target = boolean
	
func unload_laundry():
	var laundry_to_give = .unload_laundry()
	if laundry_to_give:
		emit_signal("released")
		return laundry_to_give
	return null
	
func load_laundry(laundry_in):
	
	.load_laundry(laundry_in)
	if laundry:
		emit_signal("returned")
		print("returned")

func set_state_pickup():
	can_give = false
	can_receive = true
	
	
	
