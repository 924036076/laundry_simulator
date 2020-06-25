extends Node

signal score_update

func update_score(addition : float):
	emit_signal("score_update", addition)
