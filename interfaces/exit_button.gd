extends TextureButton

var highlight_modulate = Color(.93, .86, .65)
var normal_modulate = Color(1,1,1)


func _on_ExitButton_mouse_exited():
  modulate = normal_modulate


func _on_ExitButton_mouse_entered():
  modulate = highlight_modulate


func _on_ExitButton_pressed():
  modulate = normal_modulate


func _on_ExitButton_focus_entered():
  modulate = highlight_modulate


func _on_ExitButton_focus_exited():
  modulate = normal_modulate
