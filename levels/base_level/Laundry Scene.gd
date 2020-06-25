extends Node2D

onready var nav2d : Navigation2D = $Navigation2D
onready var player : KinematicBody2D = $Objects/Player
onready var cat : KinematicBody2D = $Objects/Cat
var counters
#var customers

# Called when the node enters the scene tree for the first time.
func _ready():
	counters = $Objects/Counters.get_children()
	#customers = $Objects/Customers.get_children()
	initialize_level()
	
			
func initialize_level():
	for counter in counters:
		#var laundry = preload("res://models/laundry/laundry.tscn").instance()
		#counter.load_laundry(laundry) #debug
		counter.connect("click", $Objects/Player, "_on_Interactable_click")
	$Spawner.init($Navigation2D, player)

# Called when player clicks on screen but not on an interactable
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index == BUTTON_RIGHT:
		$Spawner.create_and_send_customer(1)
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return

	player.set_targetobjct(null)
	player.set_target_location(get_global_mouse_position())
	#cat.set_target_location(get_global_mouse_position())

func _on_HUD_new_game():
	player.reset()
	player.enable(true)
	$HUD.hide_overlay()
	$Spawner.restart()
	$MoneyLabel.reset()
	$Clock.restart()
	refresh_interactables()
	$BackgroundMusic.restart()

func refresh_interactables():
	print("REFRESHING")
	get_tree().call_group("InteractableObjects", "reset")
	
func _on_day_over():
	$Clock.stop()
	$Spawner.stop()
	$Spawner.get_angry()
	$HUD.show_overlay("Daily earnings: " + $MoneyLabel.text)
	player.enable(false)

func _on_RestartDay_restart_button_pressed():
	$Clock.stop()
	$Spawner.stop()
	$Spawner.reset()
	refresh_interactables()
	$HUD.show_overlay(null)
	player.reset()
	player.enable(false)
