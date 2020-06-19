extends "res://models/interactable/Interactable.gd"

var state_machine : AnimationNodeStateMachinePlayback

func _ready():
	._ready()
	offset = Vector2(0,5)
	state_machine = $AnimationTree["parameters/StateMachine/playback"]
	state_machine.start("idle")
	$AnimationTree.set("parameters/Blend/blend_amount", 0)
	
func load_laundry(laundry_in):
	.load_laundry(laundry_in)
	if !laundry:
		return
	laundry.position = offset
	if can_run():
		_start_load()
		_change_laundry_state()

func _change_laundry_state():
	laundry.wash()
	
func can_run() -> bool:
	return laundry.can_wash()
	
func _start_load():
	laundry.visible = false
	interactable = false
	state_machine.travel("running")
	$Timer.start()

func _finish_load():
	state_machine.travel("idle")
	laundry.visible = true
	interactable = true
	
func reset():
	.reset()
	state_machine.travel("idle")
	$Timer.stop()
	interactable = true
	
func disallowed_action():
	$AnimationTree.set("parameters/Blend/blend_amount", 0.5)
	yield(get_tree().create_timer(0.4), "timeout")
	$AnimationTree.set("parameters/Blend/blend_amount", 0)
