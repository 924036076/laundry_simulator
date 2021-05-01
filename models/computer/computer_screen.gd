extends CanvasLayer
var highlight_modulate = Color(.93, .86, .65)
var normal_modulate = Color(1,1,1)
var can_buy := false

const LAUNDRY_SITE = "http://rubitout.xxx"
const BUSINESS_SITE = "http://totally-legit-business-schemes.laundry"
const LAUNDRY_SITE_MESSAGE = "oh baby"


func _ready():
  $Screen/ExitButton.modulate = normal_modulate


func enable_purchase():
  can_buy = true


func _on_ExitButton_pressed():
  close_screen()


func close_screen():
  $AnimationPlayer.play_backwards("expand")
  $Off.play()
  yield($AnimationPlayer, "animation_finished")
  queue_free()


func _on_ExitButton_mouse_entered():
  $Screen/ExitButton.modulate = highlight_modulate


func _on_ExitButton_mouse_exited():
  $Screen/ExitButton.modulate = normal_modulate


func _on_BuyButton_pressed():
  print("pressed!")
  $AnimationPlayer.play("pending")


func _on_AnimationPlayer_animation_finished(anim_name):
  match anim_name:
    "pending":
      if can_buy:
        $AnimationPlayer.play("success")
        EventHub.emit_signal("add_money", -75000)
      else:
        $AnimationPlayer.play("error")
        $Error.play()
    "error":
      close_screen()
    "success":
      EventHub.emit_signal("laundromat_purchased")
      # TODO: load regular laundry scene


func _on_LineEdit_focus_entered() -> void:
  var line_edit = $Screen/SearchBar/LineEdit
  line_edit.text = "http://"
  line_edit.caret_position = line_edit.text.length()


func _on_LineEdit_text_changed(new_text: String) -> void:
  var line_edit = $Screen/SearchBar/LineEdit
  line_edit.text = LAUNDRY_SITE.substr(0, new_text.length())
  line_edit.caret_position = new_text.length()


func _on_LineEdit_text_entered(_new_text: String) -> void:
  var line_edit = $Screen/SearchBar/LineEdit
  line_edit.text = LAUNDRY_SITE
  line_edit.caret_position = LAUNDRY_SITE.length()
  $Screen/LaundryLove/VideoPlayer.play()
  $Screen/Ad.visible = false
  $Screen/LaundryLove.visible = true
  $Screen/BackButton.disabled = false
  EventHub.emit_signal("interactable_broadcasted", LAUNDRY_SITE_MESSAGE)


func _on_BackButton_mouse_entered():
  $Screen/BackButton.modulate = highlight_modulate


func _on_BackButton_mouse_exited():
  $Screen/BackButton.modulate = normal_modulate


func _on_BackButton_pressed() -> void:
  var line_edit = $Screen/SearchBar/LineEdit
  line_edit.text = BUSINESS_SITE
  $Screen/BackButton.disabled = true
  $Screen/Ad.visible = true
  $Screen/LaundryLove.visible = false
  $Screen/LaundryLove/VideoPlayer.stop()

