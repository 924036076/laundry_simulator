extends Node

func restart():
	$SongLoop.stop()
	$SongIntro.play()
