extends Node2D

var wet := false
var dirty := true
var bloody := false
var soiled := false
var hairy := false
var folded := false
var starting_cleanliness := 1.0
const highest_unfinished_score := 0.25
const washable_modulation := Color(0.67, 0.67, 0.67)
const dryable_modulation := Color(0.85, 0.85, 0.85)
const default_modulation := Color(1, 1, 1)
enum size {small, medium, large} #TODO: something with size
var id : int setget set_id


func set_id(new_id : int):
  id = new_id
  $Ticket/Label.text = str(id)


func _ready() -> void:
  update_visuals()
  starting_cleanliness = assess_cleanliness()


func can_wash() -> bool:
  return dirty or hairy


func can_dry() -> bool:
  return wet


func can_lint_roll() -> bool:
  return hairy


func can_fold() -> bool:
  return !dirty and !wet and !folded


func hairify() -> void:
  hairy = true
  update_visuals()


func dehairify() -> void:
  hairy = false
  update_visuals()


func wash() -> void:
  dirty = false
  wet = true
  folded = false
  update_visuals()


func dry() -> void:
  wet = false
  folded = false
  update_visuals()


func fold() -> void:
  $AnimationPlayer.play("fold")
  folded = true


func update_visuals() -> void:
  update_modulation()
  update_particles()


func update_modulation() -> void:	
  if can_wash():
    $Sprite.modulate = washable_modulation
  elif can_dry():
    $Sprite.modulate = dryable_modulation
  else:
    $Sprite.modulate = default_modulation


func update_particles() -> void:
  # Emitting changes whether particles are produced, visible whether they're visible
  # Only changing emitting results in lingering particles being visible after a state change

  $"Dirt Particles".emitting = dirty
  $"Dirt Particles".visible = dirty
  $"Drip Particles".emitting = wet
  $"Drip Particles".visible = wet
  $"Hair Particles".emitting = hairy
  $"Hair Particles".visible = hairy


func assess_cleanliness() -> float:
  var conditions = [wet, dirty, bloody, soiled, hairy]
  var max_score : int = conditions.size()
  var score : float = 0.0
  
  for state in conditions:
    if !state: score += 1
  var cleanliness = score/max_score
  if cleanliness < 1:
    cleanliness = min(cleanliness, highest_unfinished_score)
  return cleanliness


func score_laundry() -> float:
  # TODO: Better laundry scoring
  # (Currently doesn't make sense if more variables are introduced in gameplay)
  var score : float = 0.0
  var current_cleanliness = assess_cleanliness()
  if current_cleanliness > starting_cleanliness:
    score = current_cleanliness - starting_cleanliness
  return score


func show_ticket() -> void:
  $Ticket/Label.text = str(id)
  $Ticket.visible = true


func _on_Area2D_get_hairy():
  hairify()


func _on_AnimationPlayer_animation_finished(anim_name):
  if anim_name == "fold":
    EventHub.emit_signal("folding_anim_completed", self)
