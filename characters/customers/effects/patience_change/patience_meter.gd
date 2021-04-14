extends Node2D
var max_patience setget set_max_patience
var patience : float
var extra_patience_pct := 1.5
var warning_pct := 0.25
signal patience_exhausted

func set_max_patience(value : float) -> void:
  max_patience = value
  patience = max_patience
  $MainBar.max_value = max_patience
  $ExtraBar.max_value = max_patience * extra_patience_pct
  $PatienceParticles.emitting = false
  $HappyParticles.emitting = false
  update_bars()
  
func update_patience(patience_change : float) -> void:
  patience += patience_change
  update_bars()
  show_change(patience_change)
  if patience >= max_patience:
    $HappyParticles.emitting = true
  else:
    $HappyParticles.emitting = false
  if patience < max_patience * warning_pct:
    $PatienceParticles.emitting = true
  if patience <= 0:
    emit_signal("patience_exhausted")
  
func show_change(change : float) -> void:
  var patience_point = preload("res://characters/customers/effects/patience_change/patience_point.tscn").instance()
  $PointChange.call_deferred("add_child", patience_point)
  patience_point.call_deferred("set_and_show", round(change * 100))
  
func is_max() -> bool:
  return true if patience >= max_patience else false

func update_bars() -> void:
  $MainBar.value = patience
  $ExtraBar.value = patience

func get_patience() -> float:
  return patience

func on_drop_off() -> void:
  $PatienceParticles.emitting = false
