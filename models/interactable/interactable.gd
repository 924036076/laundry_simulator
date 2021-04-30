extends Area2D
class_name Interactable

export var description := "this doesn't interest me"

const default_modulation := Color(1, 1, 1, 1)
const selected_modulation := Color(0.83, 1, 0.89, 1)
var is_target := false setget set_target
var interactable := true setget set_interactable
var mouse_over := false setget _mouse_over
var radius := 0.0


func _ready() -> void:
  _calculate_radius()


func reset() -> void:
  pass


func selective_click_me(type : String):
  if name.to_lower() in type:
    click_me()
  else:
    $BaseAnimPlayer.play("idle")


func click_me():
  $BaseAnimPlayer.play("click_me")


func _calculate_radius() -> void:
  # Default method for calculating interaction radius for rectangular interactables
  # Overridden for any interactables with circular colliders

  var extents =  get_node("CollisionShape2D").shape.get_extents()
  # Halving the smallest extent by two for better controlability/feel
  radius = min(extents.x, extents.y)/2


func set_target(boolean) -> void:
  is_target = boolean
  modulate()


func disallowed_action() -> void:
  # Overriden by scenes that inherit
  pass


func interact() -> void:
  # Overriden by scenes that inherit
  EventHub.emit_signal("interactable_broadcasted", description)
  $BaseAnimPlayer.play("idle")


func modulate() -> void:
  if is_target or mouse_over and interactable:
    $Sprite.modulate = selected_modulation
  else:
    $Sprite.modulate = default_modulation


func _on_mouse_entered() -> void:
  mouse_over = true
  modulate()


func _on_mouse_exited() -> void:
  mouse_over = false
  modulate()


func set_interactable(boolean) -> void:
  interactable = boolean
  modulate()


func _mouse_over(over : bool) -> void:
  mouse_over = over


func _on_Interactable_input_event(_viewport, event, _shape_idx):
  if get_tree().is_input_handled(): return
  if not event is InputEventMouseButton: return
  if event.button_index != BUTTON_LEFT: return
  if not event.is_pressed(): return
  get_tree().set_input_as_handled()
  EventHub.emit_signal("click", self)
