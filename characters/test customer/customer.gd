extends "res://Characters/base_character/base_character.gd"

var return_destination : Vector2 setget set_return_destination
var register : Vector2 
var my_laundry
signal score

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	set_physics_process(false)
	speed = 100
	my_laundry = preload("res://models/laundry/laundry.tscn").instance()
	$Area2D.load_laundry(my_laundry)
	$Area2D.connect("released", self, "drop_off")
	$Area2D.connect("returned", self, "receive_order")
	$Ticket.visible = false
	print("customer initialized and reporting for duty!")

func set_id(id : int):
	if my_laundry:
		my_laundry.id = id
		$Ticket/Label.text = str(id)
		print("the id is: " + str(id))
	else:
		print_debug("ERROR: no laundry to give id")

func set_nav_node(node : Navigation2D):
	navNode = node
	print(navNode)

func send_off(destination : Vector2):
	register = destination
	set_target_location(register)
	$Area2D.interactable = true

func set_return_destination(destination : Vector2):
	return_destination = destination
	
func drop_off():
	$Area2D.interactable = false
	$Ticket.visible = true
	my_laundry.show_ticket()
	$Timer.start()	
	leave_store()
	
func receive_order():
	print("received order!")
	$Area2D.interactable = false
	$Ticket.visible = false
	assess_laundry()
	leave_store()
	
func leave_store():
	print("leaving!")
	set_target_location(return_destination)

func assess_laundry():
	print("hmmm maybe")
	var score : float = 0.0
	if $Area2D.laundry == my_laundry:
		print("it's my order!")
		score = my_laundry.assess_cleanliness()
	emit_signal("score", score)
	print("your score is: " + str(score))

func _on_Timer_timeout():
	print("let's get that laundry now!")
	set_target_location(register)
	$Area2D.interactable = true
