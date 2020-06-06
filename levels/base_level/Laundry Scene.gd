extends Node2D

onready var nav2d : Navigation2D = $Navigation2D
onready var line2d : Line2D = $Line2D
onready var player : Sprite = $Objects/Player
var counters_in
var counters_out # Distinction between type of counters will go away in future

# Called when the node enters the scene tree for the first time.
func _ready():
	counters_in = $Objects/Counters_In.get_children()
	counters_out = $Objects/Counters_Out.get_children()
	generate_laundry()
	
			
func generate_laundry():
	# Mostly for debugging purposes right now
	# Will have customers come in with laundry for actual gameplay
	for counter in counters_in:
		var laundry = preload("res://models/laundry/laundry.tscn").instance()
		counter.load_laundry(laundry)
		counter.connect("click", $Objects/Player, "_on_Interactable_click")
		
	for counter in counters_out:
		counter.connect("click", $Objects/Player, "_on_Interactable_click")

# Called when player clicks on screen but not on an interactable
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	# For debugging pathfinding purposes:
	#var new_path = nav2d.get_simple_path(player.global_position, event.global_position, true)
	#line2d.points = new_path
	player.set_target_location(event.global_position)
