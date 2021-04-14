extends LaundryHolder
class_name Washer

var state_machine : AnimationNodeStateMachinePlayback


func _ready() -> void:
  ._ready()
  state_machine = $AnimationTree["parameters/StateMachine/playback"]
  state_machine.start("idle")
  $AnimationTree.set("parameters/Blend/blend_amount", 0)


func load_laundry(laundry_in : Node2D) -> void:
  .load_laundry(laundry_in)
  if !laundry: return
  
  if !can_run(): return
  _start_load()


func _change_laundry_state() -> void:
  laundry.wash()
  laundry.dehairify()
  EventHub.emit_signal("laundry_washed")


func can_run() -> bool:
  return laundry.can_wash()


func _start_load() -> void:
  laundry.visible = false
  set_interactable(false)
  state_machine.travel("running")
  $AudioStreamPlayer.play()
  $Timer.start()


func _finish_load() -> void:
  _change_laundry_state()
  state_machine.travel("idle")
  $AudioStreamPlayer.stop()
  laundry.visible = true
  set_interactable(true)


func reset() -> void:
  .reset()
  state_machine.travel("idle")
  $Timer.stop()
  $AudioStreamPlayer.stop()
  interactable = true


func disallowed_action() -> void:
  # Blends the "shake" animation with the current animation (running or idle) for 0.4 seconds
  # TODO: set length of shake from settings file
  $AnimationTree.set("parameters/Blend/blend_amount", 0.5)
  yield(get_tree().create_timer(0.4), "timeout")
  $AnimationTree.set("parameters/Blend/blend_amount", 0)


func selective_click_me(type : String):
  if state_machine.get_current_node() != "idle": return
  if name.to_lower() in type:
    click_me()
  else:
    $BaseAnimPlayer.play("idle")
