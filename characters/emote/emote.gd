extends AnimatedSprite
class_name Emote


func _on_animation_finished():
  queue_free()


func set_and_play(emotion) -> void:
  match emotion:
    Types.Emotion.HAPPY:
      play("happy")
      $HappySoundPlayer.play()
    Types.Emotion.MAD:
      play("mad")
      $MadSoundPlayer.play()
    Types.Emotion.TWITCHY:
      play("twitchy")
      $MehSoundPlayer.play()
    _:
      play("twitchy")
      $MehSoundPlayer.play()
      push_error("unrecognized emotion to emote")
      print("emotion: ", str(emotion))

