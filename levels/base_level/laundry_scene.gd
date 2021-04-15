extends Node2D
class_name LaundryScene

onready var nav2d : Navigation2D = $Map/Navigation2D
onready var player : KinematicBody2D = $Map/Objects/Player
onready var cat : Cat = $Map/Objects/Cat
var counters
enum State {TITLE, GAME_OVER, DAY_OVER, PLAYING}
var state = State.TITLE


func _ready() -> void:
  counters = $Map/Objects/Counters.get_children()
  initialize_level()
  EventHub.connect("new_day", self, "_on_new_day")
  EventHub.connect("new_game", self, "_on_new_game")
  EventHub.connect("day_over", self, "_on_day_over")
  EventHub.connect("game_over", self, "_on_game_over")
  EventHub.connect("restart", self, "_on_restart")
  EventHub.connect("new_customer", self, "_on_new_customer")
  EventHub.connect("customer_card_removed", self, "_on_customer_card_removed")


func initialize_level() -> void:
  $Spawner.init(nav2d, player)


func _on_new_game() -> void:
  _on_new_day()


func refresh_interactables() -> void:
  get_tree().call_group("InteractableObjects", "reset")


func _on_day_over() -> void:
  if state == State.DAY_OVER:
    return
  state = State.DAY_OVER
  stop()
  #$HUD.show_day_end($MoneyLabel.money, prev_balance, day_count)


func stop() -> void:
  player.enable_movement(false)
  cat.stop()


func _on_new_day() -> void:
  print("root on new day")
  state = State.PLAYING
  refresh_interactables()
  cat.start()
  player.reset()
  player.enable_movement(true)
  #prev_balance = $MoneyLabel.money


func _on_restart() -> void:
  state = State.TITLE
  stop()
  refresh_interactables()
  player.reset()


func _on_Cat_mischief_wanted():
  # Give cat location of counter with laundry
  var location := Vector2.ZERO
  var id : int

  # TODO: better way of selecting location
  # (Like randomly choosing an occupied counter or having preference for clean laundry)
  for counter in counters:
    if counter.laundry_available:
      location = counter.get_jump_launch_position()
      id = counter.get_instance_id()
  cat.manage_mischief(location, id)


func _on_game_over():
  if state == State.GAME_OVER:
    print("already in game over state")
    return
  print("game over signal received at root")
  state = State.GAME_OVER
  stop()
  #$HUD.show_game_over($MoneyLabel.money)


func _on_Toy_new_destination(new_pos):
  $Destination.global_position = new_pos


func _on_new_customer(customer_name : String):
  var card = preload("res://interfaces/customer_card.tscn").instance()
  card.init(customer_name)
  $CardHolder.call_deferred("add_child", card)
  card.call_deferred("play_new_card")
  get_tree().paused = true


func _on_customer_card_removed():
  get_tree().paused = false
