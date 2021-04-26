extends CanvasLayer
class_name HUD

var overlay : Control
var story_key = null


func _ready() -> void:
  show_title_screen()
  EventHub.connect("restart", self, "_on_restart")
  EventHub.connect("game_over", self, "_on_game_over")
  EventHub.connect("day_over", self, "_on_day_over")
  EventHub.connect("laundry_times_closed", self, "_on_laundry_times_closed")
  EventHub.connect("laundry_times_unlocked", self, "_on_laundry_times_unlocked")


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
  overlay.connect("start_button_pressed", self, "_on_start_pressed")


func hide_overlay() -> void:
  if is_instance_valid(overlay):
    overlay.queue_free()


func _on_day_over():
  var total_money = GameLogic.get_player_money()
  var previous_balance = GameLogic.get_previous_balance()
  var day_count = GameLogic.get_day_count()
  
  call_deferred("show_day_end", total_money, previous_balance, day_count)


func show_day_end(total : int, prev_balance : int, day_count : int):
  if is_instance_valid(overlay):
    if overlay.get_name() == "DayEndScreen" or overlay.get_name() == "GameOverScreen":
      return
    else:
      overlay.queue_free()
  overlay = preload("res://interfaces/day_end_screen.tscn").instance()
  overlay.set_values(total, prev_balance, day_count)
  add_child(overlay)
  overlay.connect("next_day_button_pressed", self, "_on_next_day_pressed")


func _on_next_day_pressed() -> void:
  if story_key != null:
    _open_laundry_times()
    return
  EventHub.emit_signal("new_day")
  $AudioStreamPlayer.play()
  hide_overlay()


func _on_laundry_times_unlocked(key):
  story_key = key


func _open_laundry_times() -> void:
  hide_overlay()
  var laundry_times = preload("res://laundry_times/laundry_times.tscn").instance()
  add_child(laundry_times)
  laundry_times.initialize(story_key)
  story_key = null


func _on_laundry_times_closed(_key) -> void:
  EventHub.emit_signal("new_day")
  $AudioStreamPlayer.play()
  hide_overlay()


func _on_start_pressed() -> void:
  EventHub.emit_signal("new_game")
  hide_overlay()
  $AudioStreamPlayer.play()


func _on_restart():
  show_title_screen()


func _on_game_over():
  show_game_over(GameLogic.get_player_money())
