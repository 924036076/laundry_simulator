extends Label


func _ready():
  EventHub.connect("new_day", self, "_set_current_day")
  EventHub.connect("new_game", self, "_set_current_day")
  _set_current_day()


func _set_current_day():
  text = "Day " + str(GameLogic.get_day_count())
