extends Node2D
class_name LaundryScene

onready var nav2d : Navigation2D = $Navigation2D
onready var player : KinematicBody2D = $Objects/Player
onready var cat : Cat = $Objects/Cat
var counters
var day_count := 1
var prev_balance := 0


func _ready() -> void:
	counters = $Objects/Counters.get_children()
	initialize_level()


func initialize_level() -> void:
	$Spawner.init($Navigation2D, player)


func _unhandled_input(event: InputEvent) -> void:
	# Called when player clicks on screen but not on an interactable
	
	# Only handle mouse clicks
	if not event is InputEventMouseButton: return
	if not event.pressed: return
	
	match event.button_index:
		BUTTON_RIGHT:
			# Send customers on demand for debug purposes
			$Spawner.create_and_send_customer(1)
		BUTTON_LEFT:
			# Send player to clicked location and reset player's target object
			player.set_targetobjct(null)
			player.set_target_location(get_global_mouse_position())


func _on_new_game() -> void:
	day_count = 1
	prev_balance = 0
	$MoneyLabel.reset()
	_on_new_day()

func refresh_interactables() -> void:
	get_tree().call_group("InteractableObjects", "reset")


func _on_day_over() -> void:
	$Clock.stop()
	$Spawner.stop()
	$Spawner.get_angry()
	#$HUD.show_overlay($MoneyLabel.money) # show daily earnings here
	player.enable_movement(false)
	cat.stop()
	var day_end_screen = preload("res://interfaces/day_end_screen.tscn").instance()
	print("previous balance: ", prev_balance)
	day_end_screen.set_values($MoneyLabel.money, prev_balance, day_count)
	$HUD.add_child(day_end_screen)
	day_end_screen.connect("next_day_button_pressed", self, "_on_new_day")
	prev_balance = $MoneyLabel.money
	day_count += 1
	print("previous balance: ", prev_balance)


func _on_new_day() -> void:
	$Clock.restart()
	refresh_interactables()
	$BackgroundMusic.restart()
	cat.start()
	player.reset()
	player.enable_movement(true)
	$HUD.hide_overlay()
	$Spawner.restart()


func _on_restart_button_pressed() -> void:
	$Clock.stop()
	$Spawner.stop()
	$Spawner.reset()
	refresh_interactables()
	$HUD.show_overlay(0)
	player.reset()
	player.enable_movement(false)
	cat.stop()


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
