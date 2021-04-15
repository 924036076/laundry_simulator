extends LaundryHolder
class_name Bumper

signal released
signal returned
signal disallowed_customer_action
signal modulate
var initialized := false


func _ready() -> void:
  can_receive = false
  laundry_parent = $HandPos


func _calculate_radius() -> void:
  radius =  $CollisionShape2D.shape.radius


func unload_laundry() -> Node2D:
  var laundry_to_give := .unload_laundry()
  set_target(false)
  if laundry_to_give:
    emit_signal("released")
    return laundry_to_give
  return null


func load_laundry(laundry_in : Node2D) -> void:
  .load_laundry(laundry_in)
  set_target(false)
  if !laundry: return
  if initialized: emit_signal("returned")
  else: initialized = true


func set_state_pickup() -> void:
  can_give = false
  can_receive = true


func disallowed_action() -> void:
  emit_signal("disallowed_customer_action")


func modulate() -> void:
  if interactable and (mouse_over or is_target):
    emit_signal("modulate", selected_modulation)
  else:
    emit_signal("modulate", default_modulation)
