extends Node2D

var navNode : Navigation2D 
var register : Vector2 
var player : KinematicBody2D
var next_id : int = 0
var next_customer_min : float = 3.0
var next_customer_max : float = 15.0
var customer_wait_min : float = 20.0
var customer_wait_max : float = 30.0

var LAST_CUSTOMER_HOUR : int = 14

func set_register(position : Vector2):
	register = position
	print("I've got a destination to tell the customers now!")

func init(node : Navigation2D, destination : Vector2, body : KinematicBody2D):
	navNode = node
	register = destination
	player = body

func send_customer():
	# Create and initialize new customer
	var customer = preload("res://characters/test customer/customer.tscn").instance()
	$Customers.add_child(customer)
	customer.init(navNode, next_id, global_position, rand_range(customer_wait_min, customer_wait_max))
	
	# Connect the appropriate signals
	customer.connect("leaving", self, "_move_line")
	customer.connect("score", get_parent().get_node("Events"), "update_score")
	customer.get_node("Bumper").connect("click", player, "_on_Interactable_click")
	customer.send_off(register)
	
	next_id += 1

func _on_Timer_timeout():
	send_customer()
	$Timer.set_wait_time(rand_range(next_customer_min, next_customer_max))
	
func reset():
	next_id = 0

func start():
	send_customer()
	$Timer.start()
	
func stop():
	$Timer.stop()
	for child in $Customers.get_children():
		child.queue_free()

func _on_Clock_new_hour(hour : int):
	if hour >= LAST_CUSTOMER_HOUR:
		$Timer.stop()
		
func _move_line(index : int):
	for i in range(index, $Customers.get_child_count()):
		var child = $Customers.get_child(i)
		if child.current_state == child.State.waiting:
			child.set_target_location(register)
			yield(get_tree().create_timer(.75), "timeout")
			
func move_to_end(node : KinematicBody2D):
	var count = $Customers.get_child_count()
	$Customers.move_child(node, count-1)
