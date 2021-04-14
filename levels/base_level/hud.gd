extends CanvasLayer
class_name HUD

var overlay : Control


func _ready() -> void:
  show_title_screen()
  EventHub.connect("restart", self, "_on_restart")


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
    print("overlay name: ", overlay.get_name())
    if overlay.get_name() == "TitleScreen":
      return
    else:
      overlay.queue_free()
      
  overlay = preload("res://interfaces/title_screen.tscn").instance()
  add_child(overlay)
  overlay.connect("start_button_pressed", self, "_on_start_pressed")


func hide_overlay() -> void:
  if is_instance_valid(overlay):
    overlay.queue_free()


func show_day_end(total : int, prev_balance : int, day_count : int):
  if is_instance_valid(overlay):
    if overlay.get_name() == "DayEndScreen":
      return
    else:
      overlay.queue_free()
  overlay = preload("res://interfaces/day_end_screen.tscn").instance()
  overlay.set_values(total, prev_balance, day_count)
  add_child(overlay)
  overlay.connect("next_day_button_pressed", self, "_on_next_day_pressed")


func _on_next_day_pressed() -> void:
  EventHub.emit_signal("new_day")
  $AudioStreamPlayer.play()
  hide_overlay()


func _on_start_pressed() -> void:
  EventHub.emit_signal("new_game")
  hide_overlay()
  $AudioStreamPlayer.play()


func _on_restart():
  show_title_screen()



  
