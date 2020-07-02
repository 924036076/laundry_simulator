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
var enabled : bool = false

signal mischief
signal shedding
signal idle

func _ready() -> void:
	animated = true #in the future all characters will be animated, just not now
	animationState = $AnimationTree["parameters/playback"]
	money_label_offset = Vector2(0, -42)
	speed = 75
	assert($AnimationTree.active == true, "cat's Animation Tree is not active")
	
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
	if desk_path:
		desk = get_node(desk_path)

func _on_end_of_path() -> void:
	._on_end_of_path()
	match state:
		State.PATROL:
			animationState.travel("patrol")
			# TODO: remove magic numbers and populate with settings file
			$WaitTimer.start(rng.randi_range(2, 4))
		State.SLEEP:
			animationState.travel("sleep")
			emit_signal("shedding")
			$WaitTimer.start(5)
		State.WORK:
			animationState.travel("working")
			$WaitTimer.start(rng.randi_range(3, 8))
		State.MISCHIEF:
			$ThoughtBubble.hide()
			animationState.travel("jump_forward")

func _on_jump_start() -> void:
	if !enabled: return
	
	global_position = target + Vector2(0,28)
	state = State.SLEEP
	$AnimationTree.set("parameters/Idle/blend_position", Vector2.DOWN)
	$AnimationTree.set("parameters/Move/blend_position", Vector2.DOWN)
	_on_end_of_path()

func _on_WaitTimer_timeout() -> void:
	if state == State.WORK:
		show_money_earned(rng.randf_range(10.0, 50.0))
	if enabled:
		choose_action()

func manage_mischief(counter_pos : Vector2) -> void:
	target = counter_pos
	if target == Vector2.ZERO:
		animationState.travel("disappointed")
	else:
		animationState.travel("excited")

func _on_done_reacting() -> void:
	# Called from disappointed and excited animations
	if !enabled:
		return
	if target == Vector2.ZERO:
		$ThoughtBubble.hide()
		state = State.PATROL
		_on_end_of_path()
	else:
		set_target_location(target)

func office_work() -> void:
	set_target_location(desk.global_position)
	
func choose_action() -> void:
	if !enabled: return
	
	# Wait until sprite has reached idle animation
	animationState.travel("Idle")
	yield(self, "idle")
	
	# Decide on action based on cutoff values
	var random = rng.randi_range(0, 100)
	if random < patrol_cutoff:
		state = State.PATROL
		random_destination()
	elif random < sleep_cutoff:
		state = State.SLEEP
		random_destination()
	elif random < work_cutoff:
		state = State.WORK
		office_work()
	else:
		state = State.MISCHIEF
		_start_thinking()

func _start_thinking() -> void:
	animationState.travel("thinking")
	$ThoughtBubble.show()

func _on_done_thinking() -> void:
	# Called at end of thinking animation
	if enabled:
		emit_signal("mischief")
	
func random_destination() -> void:
	var patrol_index = rng.randi_range(0,  patrol_points.size()-1)
	set_target_location(patrol_points[patrol_index])
	
func stop() -> void:
	enabled = false
	$ThoughtBubble.hide()
	state = State.SLEEP
	_on_end_of_path()
	$WaitTimer.stop()
		
func start() -> void:
	enabled = true
	choose_action()
	
func _emit_idle() -> void:
	# Called from idle animation
	emit_signal("idle")
