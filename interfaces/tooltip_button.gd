extends Button
export var tooltip_enabled : String
export var tooltip_disabled : String


func disable_button():
  disabled = true
  $Label.text = tooltip_disabled


func _ready():
  $Label.visible = false
  if disabled:
    $Label.text = tooltip_disabled
  else:
    $Label.text = tooltip_enabled
  
  var x_max = rect_size.x
  $Line2D.points[1].x = x_max


func _on_Button_mouse_entered():
  grab_focus()


func _on_Button_focus_entered():
  $Label.visible = true
  $AnimationPlayer.play("focus")


func _on_Button_focus_exited():
  $Label.visible = false
  $AnimationPlayer.play("idle")
