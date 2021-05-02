extends NinePatchRect

const QUIT_MESSAGE = "Are you sure you want to disappoint your grandparents and give up on your dream?"
const ACCEPT_MESSAGE = "The following amount will be billed weekly:"
enum State{QUIT, ACCEPT, DEFAULT}
var state = State.DEFAULT
signal payment_accepted
signal dialog_closed


func init_quit():
  state = State.QUIT
  $VBoxContainer/MainLabel.text = QUIT_MESSAGE
  $VBoxContainer/SupplementaryLabel.visible = false
# TODO: init_challenge for when has lawyer cat levels

func init_accept(filthy_lucre):
  state = State.ACCEPT
  $VBoxContainer/MainLabel.text = ACCEPT_MESSAGE
  $VBoxContainer/SupplementaryLabel.visible = true
  $VBoxContainer/SupplementaryLabel.text = "$" + str(filthy_lucre)


func _on_No_pressed():
  emit_signal("dialog_closed")
  queue_free() # TODO: animation away?


func _on_Yes_pressed():
  # TODO: something for challenge code
  match state:
    State.QUIT:
      EventHub.emit_signal("game_over")
      queue_free()
    State.ACCEPT:
      emit_signal("payment_accepted")
  
