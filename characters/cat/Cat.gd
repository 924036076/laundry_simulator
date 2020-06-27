extends "res://characters/base_character/base_character.gd"

export (NodePath) var patrol_path
export (NodePath) var desk_path

var desk : Node2D
var patrol_points
var rng = RandomNumberGenerator.new()
enum State {PATROL, SLEEP, WORK, MISCHIEF}
var state = State.PATROL
var patrol_cutoff : int = 10
var sleep_cutoff : int = 30
var work_cutoff : int = 50
var mischief_cutoff : int = 100
var thought_bubble : Node2D = null
var thought_bubble_offset = Vector2(0, -40)

signal mischief
signal shedding

func _ready():
	animated = true #in the future all characters will be animated, just not now
	animationState = $AnimationTree["parameters/playback"]
	money_label_offset = Vector2(0, -42)
	speed = 75
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
	if desk_path:
		desk = get_node(desk_path)

func _on_end_of_path():
	._on_end_of_path()
	print("cat reached end of path")
	match state:
		State.PATROL:
			animationState.travel("patrol")
			$WaitTimer.start(rng.randi_range(2, 4))
		State.SLEEP:
			animationState.travel("sleep")
			$Shedding.emitting = true
			emit_signal("shedding")
			$WaitTimer.start(5)
		State.WORK:
			animationState.travel("working")
			$WaitTimer.start(rng.randi_range(3, 8))
		State.MISCHIEF:
			thought_bubble.queue_free()
			animationState.travel("jump_forward")

func _on_jump_start():
	global_position = target + Vector2(0,28)
	state = State.SLEEP
	$AnimationTree.set("parameters/Idle/blend_position", Vector2.DOWN)
	$AnimationTree.set("parameters/Move/blend_position", Vector2.DOWN)
	_on_end_of_path()

func _on_WaitTimer_timeout():
	animationState.travel("Idle")
	$Shedding.emitting = false
	if state == State.WORK:
		show_money_earned(rng.randf_range(10.0, 50.0))
	while animationState.get_current_node() != "Idle":
		yield(get_tree().create_timer(1.0), "timeout")
	choose_action()

func manage_mischief(counter_pos : Vector2):
	print("managing mischief!")
	target = counter_pos
	print(target)
	if target == Vector2.ZERO:
		print("well that's a disappointment")
		animationState.travel("disappointed")
	else:
		animationState.travel("excited")

func _on_done_reacting():
	print("done reacting")
	if target == Vector2.ZERO:
		print("I'll just be sad now")
		thought_bubble.queue_free()
		choose_action(false)
	else:
		print("Yessss I'm so happy")
		set_target_location(target)

func office_work():
	set_target_location(desk.global_position)
	
func choose_action(mischief_allowed = true):
	var random = rng.randi_range(0, 100)
	print("random num for cat: ", random)
	if random < patrol_cutoff:
		print("patrol")
		state = State.PATROL
		random_patrol_destination()
	elif random < sleep_cutoff:
		print("sleep")
		state = State.SLEEP
		#currently just sleeping in random locations; this will change
		random_patrol_destination()
	elif random < work_cutoff:
		print("work")
		state = State.WORK
		office_work()
	else:
		print("mischief")
		if mischief_allowed:
			print("AAAAND mischief is allowed")
			state = State.MISCHIEF
			_start_thinking()
		else:
			choose_action(false)

func _start_thinking():
	animationState.travel("thinking")
	thought_bubble = preload("res://models/thought_bubble/ThoughtBubble.tscn").instance()
	add_child(thought_bubble)
	thought_bubble.position = money_label_offset
	thought_bubble.play()
#	yield(thought_bubble, "animation_finished")
#	print("done thinking!")  #this or "_on_done_thinking"? decisions, decisions
#	emit_signal("mischief")

func _on_done_thinking():
	# TODO: decide if want this signal or thought bubble signal
	print("done thinking!")
	emit_signal("mischief")
	
func random_patrol_destination():
	var patrol_index = rng.randi_range(0,  patrol_points.size()-1)
	set_target_location(patrol_points[patrol_index])
