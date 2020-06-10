extends "res://Characters/base_character/base_character.gd"

var return_destination : Vector2 setget set_return_destination
var register : Vector2 
var my_laundry
enum State {entering, waiting, leaving}
var current_state
var score_multiplier : int = 50

signal leaving
signal score

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	set_physics_process(false)
	speed = 100
	my_laundry = preload("res://models/laundry/laundry.tscn").instance()
	$Bumper.load_laundry(my_laundry)
	$Bumper.connect("released", self, "drop_off")
	$Bumper.connect("returned", self, "receive_order")
	$Ticket.visible = false
	print("customer initialized and reporting for duty!")
	current_state = State.entering
	print("entering is " + str(State.entering) + " and waiting is " + str(State.waiting))

func set_id(id : int):
	if my_laundry:
		my_laundry.id = id
		$Ticket/Label.text = str(id)
	else:
		print_debug("ERROR: no laundry to give id")

func set_nav_node(node : Navigation2D):
	navNode = node
	print(navNode)

func send_off(destination : Vector2):
	register = destination
	set_target_location(register)
	$Bumper.interactable = true
	current_state = State.entering

func set_return_destination(destination : Vector2):
	return_destination = destination
	
func drop_off():
	$Bumper.interactable = false
	$Ticket.visible = true
	my_laundry.show_ticket()
	$Timer.start()	
	leave_store()
	
func receive_order():
	print("received order!")
	$Bumper.interactable = false
	$Ticket.visible = false
	assess_laundry()
	leave_store()
	
func leave_store():
	print("leaving!")
	current_state = State.leaving
	set_target_location(return_destination)
	emit_signal("leaving", get_index())

func assess_laundry():
	print("hmmm maybe")
	var score : float = 0.0
	if $Bumper.laundry == my_laundry:
		print("it's my order!")
		score = my_laundry.assess_cleanliness() * score_multiplier
	emit_signal("score", score)
	print("your score is: " + str(score))

func _on_Timer_timeout():
	print("WHERE'S MY LAUNDRY??")
	set_target_location(register)
	$Bumper.interactable = true
	current_state = State.entering
	get_parent().get_parent().move_to_end(self)

func _on_Bumper_area_entered(area : Area2D):
	if area.get_name() == $Bumper.get_name(): # in another customer's grill
		var customer = area.get_parent()
		if customer.current_state != State.leaving and current_state != State.leaving:
			set_target_location(global_position) # don't go anywhere
			current_state = State.waiting

func _on_end_of_path():
	if current_state != State.leaving:
		current_state = State.waiting

