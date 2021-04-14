extends Control


signal next_day_button_pressed


func set_values(total, prev_balance, day_count) -> void:
  var values = $VBoxContainer/Earnings/Values
  values.get_node("Total").text = "$" + str(total)
  values.get_node("Previous").text = "$" + str(prev_balance)
  values.get_node("New").text = "$" + str(total-prev_balance)
  $VBoxContainer/Title.text = "Day " + str(day_count)


func _on_Button_pressed():
  emit_signal("next_day_button_pressed")
  queue_free()
