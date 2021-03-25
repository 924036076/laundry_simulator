extends Node2D
class_name LaundryScene

onready var nav2d : Navigation2D = $Navigation2D
onready var player : KinematicBody2D = $Objects/Player
onready var cat : Cat = $Objects/Cat
var counters
var day_count := 1
var prev_balance := 0
enum State {TITLE, GAME_OVER, DAY_OVER, PLAYING}
var state = State.TITLE


func _ready() -> void:
	counters = $Objects/Counters.get_children()
	initialize_level()
	$StarRating.visible = false


func initialize_level() -> void:
	$Spawner.init($Navigation2D, player)


func _unhandled_input(event: InputEvent) -> void:
	# Called when player clicks on screen but not on an interactable
	
	# Only handle mouse clicks
	if not event is InputEventMouseButton: return
	if not event.pressed: return
	
	match event.button_index:
		BUTTON_RIGHT:
			# Commands for debug purposes
			$Toy.release()
			# $Spawner.create_and_send_customer(1)
		BUTTON_LEFT:
			# Send player to clicked location and reset player's target object
			player.set_targetobjct(null)
			player.set_target_location(get_global_mouse_position())


func _on_new_game() -> void:
	day_count = 0
	prev_balance = 0
	$MoneyLabel.reset()
	$StarRating.reset()
	$StarRating.visible = true
	$Spawner.new_game()
	_on_new_day()


func refresh_interactables() -> void:
	get_tree().call_group("InteractableObjects", "reset")


func _on_day_over() -> void:
	if state == State.DAY_OVER:
		return
	state = State.DAY_OVER
	stop()
	$Spawner.get_angry()
	$HUD.show_day_end($MoneyLabel.money, prev_balance, day_count)


func stop() -> void:
	$Clock.stop()
	$Spawner.stop()
	player.enable_movement(false)
	cat.stop()


func _on_new_day() -> void:
	state = State.PLAYING
	$Clock.restart()
	refresh_interactables()
	$BackgroundMusic.restart()
	cat.start()
	$ToyHolder.new_toy()
	$Machines/LintMachine.new_lint_roll()
	player.reset()
	player.enable_movement(true)
	$HUD.hide_overlay()
	$Spawner.restart()
	$Options/PauseToggle.pressed = false
	prev_balance = $MoneyLabel.money
	day_count += 1
	print("day now: ", day_count)


func _on_restart_button_pressed() -> void:
	state = State.TITLE
	stop()
	$Spawner.reset()
	refresh_interactables()
	$HUD.show_title_screen()
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


func _on_StarRating_game_over():
	if state == State.GAME_OVER:
		print("already in game over state")
		return
	print("game over signal received at root")
	state = State.GAME_OVER
	stop()
	$StarRating.visible = false
	$Spawner.get_angry()
	$HUD.show_game_over($MoneyLabel.money)


func _on_Toy_new_destination(new_pos):
	$Destination.global_position = new_pos
