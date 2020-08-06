extends CanvasLayer
class_name HUD

signal new_game
signal new_day
var overlay : Control


func _ready():
	show_title_screen()
	Global.save(0)


func show_overlay(score := 0):
	if score != 0:
		show_game_over(score)
	else:
		show_title_screen()


func check_high_score(score: int) -> void:
	if score > Global.get_high_score():
		Global.save(score)


func show_game_over(score : int) -> void:
	check_high_score(score)
	if overlay:
		overlay.queue_free()
	overlay = preload("res://interfaces/game_over_screen.tscn").instance()
	overlay.set_scores(Global.get_high_score(), score)
	add_child(overlay)
	overlay.connect("new_game_button_pressed", self, "_on_new_game")


func show_title_screen() -> void:
	if overlay and overlay.get_name() == "TitleScreen":
		return
	if overlay:
		overlay.queue_free()
	overlay = preload("res://interfaces/title_screen.tscn").instance()
	add_child(overlay)
	overlay.connect("start_button_pressed", self, "_on_new_game")


func hide_overlay():
	if overlay:
		overlay.queue_free()


func _on_new_game():
	emit_signal("new_game")
	$AudioStreamPlayer.play()
