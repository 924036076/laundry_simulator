extends AnimatedSprite
class_name Emote


func _on_animation_finished():
  queue_free()


func set_and_play(emotion : String) -> void:
  match emotion:
    "happy":
      play("happy")
      $HappySoundPlayer.play()
    "mad":
      play("mad")
      $MadSoundPlayer.play()
    "twitchy":
      play("twitchy")
      $MehSoundPlayer.play()

