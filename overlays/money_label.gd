extends RichTextLabel

var money := 0
var daily_earnings := []


func _ready():
  money = GameLogic.get_player_money()
  format_money()
  EventHub.connect("money_updated", self, "_on_money_updated")
  EventHub.connect("money_reset", self, "_on_money_reset")


func _on_money_reset(new_value):
  money = new_value
  format_money()


func _on_money_updated(new_value):
  var difference = new_value - money
  if difference == 0: return
  _on_add_money(difference)


func _format_currency(value):
  # Assumes value is a non-negative integer
  var v := str(value)
  for i in range(v.length() - 3, 0, -3):
    v = v.insert(i, ",")
  return "$" + v


func format_money(effect = ""):
  set_bbcode("[right]" + effect + _format_currency(money))


func _on_add_money(addition : float):
# warning-ignore:narrowing_conversion
  money += round(addition)
  var color_string
  if addition > 0:
    color_string = "[color=#5dff67]"
  else:
    color_string = "[color=red]"

  format_money("[wave]" + color_string)
  $AudioStreamPlayer.play()


func _on_AudioStreamPlayer_finished():
  yield(get_tree().create_timer(1.3), "timeout")
  format_money()
