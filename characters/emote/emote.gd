extends AnimatedSprite
class_name Emote


var happy_cutoff := 0.9
var mad_cutoff := 0.25


func _on_animation_finished():
  queue_free()


func set_and_play(happiness_pct : float) -> void:
  # Happiness percent between 0 and 1 affects what is played
  if happiness_pct >= happy_cutoff:
    play("happy")
    $HappySoundPlayer.play()
    EventHub.emit_signal("good_review")
  elif happiness_pct < mad_cutoff:
    play("mad")
    $MadSoundPlayer.play()
    EventHub.emit_signal("very_bad_review")
  else:
    play("twitchy")
    $MehSoundPlayer.play()
    EventHub.emit_signal("bad_review")
