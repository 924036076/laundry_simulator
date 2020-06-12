extends Node2D

onready var nav2d : Navigation2D = $Navigation2D
onready var line2d : Line2D = $Line2D
onready var player : Sprite = $Objects/Player
onready var register : StaticBody2D = $Objects/Register
var counters
#var customers

# Called when the node enters the scene tree for the first time.
func _ready():
	counters = $Objects/Counters.get_children()
	#customers = $Objects/Customers.get_children()
	initialize_level()
	$HUD
	
			
func initialize_level():
	for counter in counters:
		#var laundry = preload("res://models/laundry/laundry.tscn").instance()
		#counter.load_laundry(laundry) #debug
		counter.connect("click", $Objects/Player, "_on_Interactable_click")
	var target = register.global_position
	$Spawner.init($Navigation2D, target, player)

# Called when player clicks on screen but not on an interactable
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return

	player.set_targetobjct(null)
	player.set_target_location(event.global_position)

func _on_HUD_new_game():
	$HUD.hide_overlay()
	$Spawner.reset()
	$Spawner.start()
	$MoneyLabel.reset()
	$Clock.reset()
	$Clock.start()
	refresh_interactables()
	player.enable(true)

func refresh_interactables():
	print("REFRESHING")
	get_tree().call_group("InteractableObjects", "reset")
	
func _on_Clock_day_over():
	$Clock.stop()
	$Spawner.stop()
	$HUD.show_overlay("Daily earnings: " + $MoneyLabel.text)
	player.enable(false)
