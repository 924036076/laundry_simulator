extends Node

signal score_update

func update_score(addition : float):
	print("Events node here")
	emit_signal("score_update", addition)
