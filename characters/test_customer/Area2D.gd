extends "res://models/laundry_holder/LaundryHolder.gd"

signal released
signal returned
signal disallowed_customer_action
signal modulate

func _ready() -> void:
	offset = Vector2(0,12)
	can_receive = false
	
func _calculate_radius() -> void:
	radius =  $CollisionShape2D.shape.radius
	
func set_target(boolean) -> void:
	is_target = boolean
	
func unload_laundry() -> Node2D:
	var laundry_to_give := .unload_laundry()
	if laundry_to_give:
		emit_signal("released")
		return laundry_to_give
	return null
	
func load_laundry(laundry_in : Node2D) -> void:
	.load_laundry(laundry_in)
	if laundry: emit_signal("returned")

func set_state_pickup() -> void:
	can_give = false
	can_receive = true
	
func disallowed_action() -> void:
	emit_signal("disallowed_customer_action")
	
func modulate() -> void:
	if mouse_over and interactable: emit_signal("modulate", selected_modulation)
	else: emit_signal("modulate", default_modulation)
