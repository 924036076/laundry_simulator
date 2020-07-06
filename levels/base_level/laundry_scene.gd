extends Node2D
class_name LaundryScene

onready var nav2d : Navigation2D = $Navigation2D
onready var player : KinematicBody2D = $Objects/Player
onready var cat : Cat = $Objects/Cat
var counters

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
	player.reset()
	player.enable_movement(true)
	$HUD.hide_overlay()
	$Spawner.restart()
	$MoneyLabel.reset()
	$Clock.restart()
	refresh_interactables()
	$BackgroundMusic.restart()
	cat.start()

func refresh_interactables() -> void:
	get_tree().call_group("InteractableObjects", "reset")
	
func _on_day_over() -> void:
	$Clock.stop()
	$Spawner.stop()
	$Spawner.get_angry()
	$HUD.show_overlay("Daily earnings: " + $MoneyLabel.text)
	player.enable_movement(false)
	cat.stop()

func _on_restart_day() -> void:
	$Clock.stop()
	$Spawner.stop()
	$Spawner.reset()
	refresh_interactables()
	$HUD.show_overlay(null)
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
