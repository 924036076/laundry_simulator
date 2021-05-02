extends BaseCharacter
class_name BaseCustomer

var return_destination : Vector2
var register : Vector2
var my_laundry : Node2D
var score_multiplier := 30
var expression_offset := Vector2(0, -83)
var buff_offset := Vector2(0, -17)
var score := 0.0
var cleanliness_pct := 0.0
var max_patience := 1.0
var patience_unit := 0.02
var received_laundry := false
var toy_bounce_effect := -5
var customer_name = "influencer"
var happy_effect = ""
var mad_effect = ""

var happy_cutoff := 0.9
var mad_cutoff := 0.25

signal leaving
signal returning


func _ready() -> void:
  ._ready()
  _on_ready()


func _on_ready() -> void:
  set_physics_process(false)
  my_laundry = preload("res://models/laundry/laundry.tscn").instance()
  $Bumper.load_laundry(my_laundry)
  $Bumper/HandPos/Ticket.visible = false
  animationState = $AnimationTree["parameters/playback"]
  assert($AnimationTree.active == true, "Customer's Animation Tree is not active")
  EventHub.connect("patience_cloud", self, "on_patience_cloud")
  EventHub.connect("toy_bounced_on_body", self, "_on_toy_bouncing")
  $PatienceMeter.set_max_patience(max_patience)


func init(node : Navigation2D, id : int, wait_time : float, shorthand = "young_man") -> void:
  navNode = node
  set_laundry_id(id)
  return_destination = global_position
  $Timer.set_wait_time(wait_time)
  customer_name = shorthand
  set_characteristics()


func set_characteristics():
  var data = Global.Customers[customer_name]
  speed = data["speed"]
  score_multiplier = data["score_multiplier"]
  patience_unit = data["patience_unit"]
  $Sprite.texture = load(data["sprite_path"])
  if data.has("ability"):
    match data["ability"]:
      "Love Hearts":
        happy_effect = "Love Hearts"


func set_laundry_id(id : int) -> void:
  if my_laundry:
    my_laundry.id = id
    $Bumper/HandPos/Ticket/Label.text = str(id)
  else:
    print_debug("ERROR: no laundry to give id")


func drop_off() -> void:
  set_physics_process(false)
  $Bumper.interactable = false
  $Bumper/HandPos/Ticket.visible = true
  my_laundry.show_ticket()
  $Timer.start()
  leave_store()
  $PatienceMeter.on_drop_off()
  var visits = Global.Customers[customer_name]["visits"]
  if visits == 0:
    EventHub.emit_signal("new_customer", customer_name)
  Global.Customers[customer_name]["visits"] = visits + 1


func receive_order() -> void:
  $Bumper.interactable = false
  $Bumper/HandPos/Ticket.visible = false
  $PatienceMeter.hide()
  assess_laundry()
  var emotion = get_emotion(cleanliness_pct)
  var expression = emote(emotion)
  leave_review(emotion)

  # TODO: work on scoring and cleaniness pct logic to be better; redo this
  if $PatienceMeter.is_max() and cleanliness_pct >= 1:
    happy_buff()
  yield(expression, "animation_finished")
  show_money_earned(score * score_multiplier, cleanliness_pct)
  received_laundry = true
  leave_store()


func get_emotion(happiness_pct):
  if happiness_pct >= happy_cutoff:
    return Types.Emotion.HAPPY
  elif happiness_pct < mad_cutoff:
    return Types.Emotion.MAD
  else:
    return Types.Emotion.TWITCHY


func leave_review(emotion):
  var review_type
  match emotion:
    Types.Emotion.HAPPY:
      review_type = Types.Review.GOOD
    Types.Emotion.MAD:
      review_type = Types.Review.VERY_BAD
    Types.Emotion.TWITCHY:
      review_type = Types.Review.BAD
    _:
      push_error("unrecognized emotion for review")
      print("emotion: ", emotion)
      review_type = Types.Review.BAD
  EventHub.emit_signal("new_review", review_type)


func happy_buff() -> void:
  if happy_effect == "Love Hearts":
    var buff = preload("res://characters/customers/effects/love_aura/love_aura.tscn").instance()
    buff.position = buff_offset
    call_deferred("add_child", buff)


func leave_store() -> void:
  set_target_location(return_destination)
  EventHub.emit_signal("customer_leaving", self)
  if received_laundry:
    EventHub.emit_signal("new_rating", score)


func assess_laundry() -> void:
  if $Bumper.laundry == my_laundry:
    cleanliness_pct = my_laundry.assess_cleanliness()
    score = cleanliness_pct * $PatienceMeter.get_patience()
  $PatienceMeter.hide()


func emote(emotion) -> AnimatedSprite:
  var expression = preload("res://characters/emote/emote.tscn").instance()
  expression.position = expression_offset
  add_child(expression)
  expression.set_and_play(emotion)
  return expression


func storm_off() -> void:
  $PatienceMeter.hide()
  received_laundry = true
  if score == 0:
    var expression = emote(Types.Emotion.MAD)
    leave_review(Types.Emotion.MAD)
    yield(expression, "animation_finished")
  leave_store()


func _on_Timer_timeout() -> void:
  back_to_store()


func back_to_store() -> void:
  EventHub.emit_signal("customer_entering", self)
  $Bumper.interactable = true
  $Bumper.set_state_pickup()


func last_call() -> void:
  $Timer.stop()
  back_to_store()


func decrement_patience() -> void:
  if received_laundry or walking:
    return
  modify_patience_points(-1)


func _on_toy_bouncing(body) -> void:
  if body != self: return
  $AnimationPlayer.play("shake")
  emote(Types.Emotion.MAD)
  modify_patience_points(toy_bounce_effect)


func _on_Bumper_disallowed_customer_action() -> void:
  $AnimationPlayer.play("shake")


func _on_end_of_path() -> void:
  ._on_end_of_path()
  if global_position.distance_to(return_destination) <= 5 and is_in_group("satisfied_customers"):
    queue_free()


func _on_Bumper_modulate(modulation : Color) -> void:
  $Sprite.modulate = modulation


func modify_patience_points(points : int) -> void:
  var addition := points * patience_unit
  $PatienceMeter.update_patience(addition)


func on_patience_cloud(cloud : Area2D, points : int) -> void:
  if !cloud.overlaps_area($Bumper): return
  if received_laundry: return
  modify_patience_points(points)


func set_target_location(location: Vector2) -> void:
  .set_target_location(location)


func _on_patience_exhausted():
  storm_off()
