extends CanvasLayer
class_name HUD

signal new_game
signal new_day
var overlay : Control


func _ready() -> void:
	show_title_screen()


func check_high_score(score: int) -> void:
	if score > Global.get_high_score():
		Global.save(score)


func show_game_over(score : int) -> void:
	print("HUD showing game over!")
	check_high_score(score)
	if is_instance_valid(overlay):
		overlay.queue_free()
	overlay = preload("res://interfaces/game_over_screen.tscn").instance()
	overlay.set_scores(Global.get_high_score(), score)
	add_child(overlay)
	overlay.connect("new_game_button_pressed", self, "_on_new_game")


func show_title_screen() -> void:
	if is_instance_valid(overlay):
		if overlay.get_name() == "TitleScreen":
			return
		else:
			overlay.queue_free()
			
	overlay = preload("res://interfaces/title_screen.tscn").instance()
	add_child(overlay)
	overlay.connect("start_button_pressed", self, "_on_new_game")


func hide_overlay() -> void:
	if overlay:
		overlay.queue_free()


func show_day_end(total : int, prev_balance : int, day_count : int):
	if is_instance_valid(overlay):
		if overlay.get_name() == "GameOverScreen":
			return
		else:
			overlay.queue_free()
	var day_end_screen = preload("res://interfaces/day_end_screen.tscn").instance()
	day_end_screen.set_values(total, prev_balance, day_count)
	add_child(day_end_screen)
	day_end_screen.connect("next_day_button_pressed", self, "_on_new_day")


func _on_new_day() -> void:
	emit_signal("new_day")
	$AudioStreamPlayer.play()


func _on_new_game() -> void:
	emit_signal("new_game")
	$AudioStreamPlayer.play()
	
