extends Node

signal score_update

# TODO: make better use of this events hub node
func update_score(addition : float):
	emit_signal("score_update", addition)
