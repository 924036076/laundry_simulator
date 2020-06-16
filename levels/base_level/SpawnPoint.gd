extends Node2D

var navNode : Navigation2D 
var player : KinematicBody2D
var next_id : int = 0
var next_customer_min : float = 3.0
var next_customer_max : float = 15.0
var customer_wait_min : float = 20.0
var customer_wait_max : float = 30.0
var queued_customers = []
var waiting_customers = []
var max_customers : int
var starting_customers : int = 3
var new_customers_on_timeout : int = 1

var LAST_CUSTOMER_HOUR : int = 14

func init(node : Navigation2D, body : KinematicBody2D):
	navNode = node
	player = body
	max_customers = $WaitingSpots.get_child_count()

func create_customer():
	# Create and initialize new customer
	var customer = preload("res://characters/test customer/customer.tscn").instance()
	$Customers.add_child(customer)
	customer.init(navNode, next_id, rand_range(customer_wait_min, customer_wait_max))
	
	# Connect the appropriate signals
	customer.connect("leaving", self, "handle_leaving")
	customer.connect("returning", self, "send_customer")
	customer.connect("score", get_parent().get_node("Events"), "update_score")
	customer.get_node("Bumper").connect("click", player, "_on_Interactable_click")
	
	next_id += 1
	
	return customer

func send_customer(customer):
	#all customers (new and returning) go to queue first
	queued_customers.append(customer)

func manage_queue():
	if !waiting_customers or len(waiting_customers) < max_customers:
		if queued_customers:
			waiting_customers.append(queued_customers.pop_front())
	_move_line()

func _on_Timer_timeout():
	create_and_send_customer(new_customers_on_timeout)
	$CustomerTimer.set_wait_time(rand_range(next_customer_min, next_customer_max))

func create_and_send_customer(num : int):
	for _i in range(num):
		send_customer(create_customer())
			
func reset():
	for child in $Customers.get_children():
		child.queue_free()
	waiting_customers = []
	next_id = 0

func start():
	create_and_send_customer(starting_customers)
	$CustomerTimer.start()
	$WaitTimer.start()
	
func stop():
	$CustomerTimer.stop()
	$WaitTimer.stop()
	queued_customers = []

func get_angry():
	if waiting_customers:
		for customer in waiting_customers:
			customer.storm_off()
			
func _on_Clock_new_hour(hour : int):
	if hour >= LAST_CUSTOMER_HOUR:
		$CustomerTimer.stop()

func _move_line():
	#assert(len(waiting_customers) <= len($WaitingSpots.get_child_count()))
	for i in range(len(waiting_customers)):
		waiting_customers[i].set_target_location($WaitingSpots.get_child(i).global_position)

func handle_leaving(customer):
	var index = waiting_customers.find(customer)
	print("index is: " + str(index))
	print("before: ", waiting_customers.size())
	waiting_customers.remove(index)
	print("after: ", waiting_customers.size())
	customer.set_target_location(global_position)

func _on_WaitTimer_timeout():
	manage_queue()
