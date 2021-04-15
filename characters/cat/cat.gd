extends BaseCharacter
class_name Cat

export (NodePath) var patrol_path
export (NodePath) var desk_path

var desk : Node2D
var patrol_points : PoolVector2Array
var rng := RandomNumberGenerator.new()
enum State {PATROL, SLEEP, WORK, PLAY, MISCHIEF, JUMPING}
var state = State.PATROL
var patrol_cutoff := 10
var sleep_cutoff := 30
var work_cutoff := 50
var mischief_cutoff := 100
var action_enabled := false
var target_id : int


signal mischief_wanted
signal mischief_started
signal idle


func _ready() -> void:
  EventHub.connect("toy_released", self, "_on_toy_released")
  EventHub.connect("toy_destroyed", self, "_on_toy_destroyed")
  animationState = $AnimationTree["parameters/playback"]
  money_label_offset = Vector2(0, -65)
  speed = 75
  assert($AnimationTree.active == true, "cat's Animation Tree is not active")

  if patrol_path:
    patrol_points = get_node(patrol_path).curve.get_baked_points()
  if desk_path:
    desk = get_node(desk_path)

  rng.randomize()


func _on_toy_released(play_loc : Vector2) -> void:
  if state == State.JUMPING or state == State.SLEEP: return
  target = play_loc
  state = State.PLAY
  $WaitTimer.stop()
  $ThoughtBubble.hide()
  set_target_location(global_position)

  animationState.travel("Idle")
  yield(self, "idle")
  animationState.travel("excited")


func _on_toy_destroyed():
  if action_enabled:
    target = Vector2.ZERO
    animationState.travel("disappointed")
  else:
    animationState.travel("sleep")



func _on_end_of_path() -> void:
  ._on_end_of_path()
  handle_state_transition()


func handle_state_transition() -> void:
  match state:
    State.PATROL:
      animationState.travel("patrol")
      # TODO: remove magic numbers and populate with settings file
      $WaitTimer.start(rng.randi_range(2, 4))
    State.SLEEP:
      animationState.travel("sleep")
      shed()
      $WaitTimer.start(5)
    State.WORK:
      animationState.travel("working")
      $WaitTimer.start(rng.randi_range(3, 8))
    State.MISCHIEF:
      emit_signal("mischief_started")
      state = State.JUMPING
      animationState.travel("jump_forward")
    State.PLAY:
      if target.distance_to(global_position) < 10:
        $AnimationTree.set("parameters/Idle/blend_position", Vector2(0, 1))
        EventHub.emit_signal("play_started")
        animationState.travel("play")


func shed() -> void:
  var areas = $Bumper.get_overlapping_areas()
  for i in areas:
    if i.is_in_group("sheddable"): i.cat_shedding()


func _on_jump_start() -> void:
  if !action_enabled: return

  global_position = target + Vector2(0,43) # TODO: smarter jumping behavior; vanquish magic number
  state = State.SLEEP
  $AnimationTree.set("parameters/Idle/blend_position", Vector2.DOWN)
  $AnimationTree.set("parameters/Move/blend_position", Vector2.DOWN)


func _on_jump_end() -> void:
  EventHub.emit_signal("occupy_object", target_id)
  handle_state_transition()
  $ThoughtBubble.hide()


func _on_play_end() -> void:
  EventHub.emit_signal("play_ended")



func _on_WaitTimer_timeout() -> void:
  match state:
    State.WORK:
      show_money_earned(rng.randf_range(10.0, 50.0))
    State.SLEEP:
      animationState.travel("Idle")
      yield(self, "idle")
      EventHub.emit_signal("leave_object", target_id)

  if action_enabled:
    choose_action()


func manage_mischief(counter_pos : Vector2, id : int) -> void:
  target = counter_pos
  target_id = id

  if target == Vector2.ZERO:
    animationState.travel("disappointed")
  else:
    animationState.travel("excited")


func _on_done_reacting() -> void:
  # Called from disappointed and excited animations
#
  if !action_enabled:
    return

  if target == Vector2.ZERO:
    $ThoughtBubble.hide()
    state = State.PATROL
    handle_state_transition()
  else:
    set_target_location(target)


func office_work() -> void:
  set_target_location(desk.global_position)


func choose_action() -> void:
  if !action_enabled: return
  if state == State.PLAY: return

  target_id = 0
  $ThoughtBubble.hide()

  # Wait until sprite has reached idle animation
  animationState.travel("Idle")
  yield(self, "idle")
  if state == State.PLAY: return

  # Decide on action based on cutoff values
  var random = rng.randi_range(0, 100)
  if random < patrol_cutoff:
    state = State.PATROL
    set_random_destination()
  elif random < sleep_cutoff:
    state = State.SLEEP
    set_random_destination()
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
  if action_enabled and state == State.MISCHIEF:
    emit_signal("mischief_wanted")
  else:
    $ThoughtBubble.hide()


func set_random_destination() -> void:
  var patrol_index = rng.randi_range(0,  patrol_points.size()-1)
  set_target_location(patrol_points[patrol_index])


func stop() -> void:
  action_enabled = false
  $WaitTimer.stop()
  $ThoughtBubble.hide()
  state = State.SLEEP
  animationState.travel("sleep")


func start() -> void:
  $ThoughtBubble.hide()
  action_enabled = true
  choose_action()


func _emit_idle() -> void:
  # Called from idle animation
  emit_signal("idle")


func _on_Bumper_modulate(modulation : Color) -> void:
  $Sprite.modulate = modulation
