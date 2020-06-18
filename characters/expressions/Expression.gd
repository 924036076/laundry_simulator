extends AnimatedSprite
var happy_cutoff : float = 0.9
var mad_cutoff : float = 0.25

func _on_animation_finished():
	queue_free()

func set_and_play(happiness_pct : float):
	# Happiness percent between 0 and 1 affects what is played
	if happiness_pct >= happy_cutoff:
		play("happy")
		$HappySoundPlayer.play()
	elif happiness_pct < mad_cutoff:
		play("mad")
		$MadSoundPlayer.play()
	else:
		play("twitchy")
		$MehSoundPlayer.play()
