extends CheckBox

signal filter_activated
var type_filter = Types.ItemType.OTHER


func init(new_filter, show_new = false):
  type_filter = new_filter
  var display_text = Types.ItemType.keys()[new_filter]
  text = display_text.to_lower() + "s"
  $New.visible = show_new


func _on_MachineCheck_pressed():
  emit_signal("filter_activated", type_filter)
  $New.visible = false
