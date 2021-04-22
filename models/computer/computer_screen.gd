extends CanvasLayer
var highlight_modulate = Color(.93, .86, .65)
var normal_modulate = Color(1,1,1)
var can_buy := false


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
