extends Control

var max_length := 168.0
var min_length := 2.0
var stars := 5
var starting_stars := 3
var decrement :=  max_length / stars * 0.25
var large_decrement := decrement * 4
var game_over = false


func _ready():
  EventHub.connect("new_review", self, "_on_new_review")
  
  EventHub.connect("new_game", self, "_on_new_game")
  EventHub.connect("game_over", self, "_on_game_over")
  visible = false


func _on_new_review(review_type):
  match review_type:
    Types.Review.GOOD:
      rect_size.x = min(rect_size.x + (decrement / 2), max_length)
    Types.Review.VERY_BAD:
      rect_size.x = max(rect_size.x - (large_decrement), 0)
      check_rating()
    Types.Review.BAD:
      rect_size.x = max(rect_size.x - decrement, 0)
      check_rating()
    _:
      push_error("unrecognized review type in star_rating")
      print("review type: ", str(review_type))


func _on_bad_review() -> void:
  rect_size.x = max(rect_size.x - decrement, 0)
  check_rating()


func _on_very_bad_review() -> void:
  rect_size.x = max(rect_size.x - (large_decrement), 0)
  check_rating()

  
func check_rating() -> void:
  print("current length: ", rect_size.x)
  if rect_size.x <= min_length and !game_over:
    game_over = true
    EventHub.emit_signal("game_over")
    print("game over from stars")


func reset() -> void:
  print("resetting stars!")
  rect_size.x = max_length / stars * starting_stars


func _on_new_game():
  reset()
  game_over = false
  visible = true


func _on_game_over():
  game_over = true
  visible = false
