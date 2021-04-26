extends Interactable
signal modulate
var cuddle_length := 3.0


func _calculate_radius() -> void:
  radius =  $CollisionShape2D.shape.radius


func modulate() -> void:
  if interactable and (mouse_over or is_target):
    emit_signal("modulate", selected_modulation)
  else:
    emit_signal("modulate", default_modulation)


func interact() -> void:
  .interact()
  $LoveParticles.emitting = true
  EventHub.emit_signal("cat_cuddled")
  $CuddleTimer.start(cuddle_length)
  if !$AudioStreamPlayer.is_playing():
    $AudioStreamPlayer.play()


func _on_Bumper_body_exited(body):
  if $LoveParticles.emitting and body.get_name() == "Player":
    stop_cuddles()


func stop_cuddles():
  $LoveParticles.emitting = false
  EventHub.emit_signal("cuddles_stopped")


func _on_CuddleTimer_timeout():
  stop_cuddles()
