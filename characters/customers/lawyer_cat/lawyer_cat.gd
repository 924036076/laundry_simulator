extends BaseCustomer


func _on_ready():
  speed = 65
  EventHub.connect("toy_bounced_on_body", self, "_on_toy_bouncing")
  animationState = $AnimationTree["parameters/playback"]
  $PatienceMeter.visible = false
  customer_name = "lawyer_cat"
  $Bumper/HandPos/Ticket.visible = false
  $Bumper/HandPos/Letter.visible = true
  set_physics_process(false)
  $AnimationTree.active = true
  EventHub.emit_signal("lawyer_cat_created")
  print("I'm a lawyer cat!")


func decrement_patience() -> void:
  pass


func init_nav(node : Navigation2D) -> void:
  navNode = node
  return_destination = global_position


func _on_Bumper_interacted():
  print("lawyer cat leaving!")
  set_physics_process(false)
  $Bumper.interactable = false
  $Bumper/HandPos/Letter.visible = false
  leave_store()
