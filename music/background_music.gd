extends Node
var master_volume : float = -8

func _ready():
	$SongIntro.set("volume_db", master_volume)
	$SongLoop.set("volume_db", master_volume)
	EventHub.connect("new_day", self, "_on_new_day")


func restart():
	# Stops the song loop (if playing) and starts the intro
	# Song Loop listens for the intro to finish, then plays and loops indefinitely
	if $SongLoop.playing:
		$SongLoop.stop() 
		$SongIntro.play()


func _on_new_day():
	restart()
