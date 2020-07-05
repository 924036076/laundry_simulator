extends Node2D

var navNode : Navigation2D 
var player : KinematicBody2D
var next_id := 0
var next_customer_min := 3.0
var next_customer_max := 15.0
var customer_wait_min := 20.0
var customer_wait_max := 32.0
var queued_customers := []
var waiting_customers := []
var max_customers : int
var starting_customers := 2
var new_customers_on_timeout := 1
var customers_created := 0
var customers_served := 0
const LAST_CUSTOMER_HOUR := 16 # TODO: have this connected to clock then send signal
signal day_over

func init(node : Navigation2D, body : KinematicBody2D) -> void:
	navNode = node
	player = body
	max_customers = $WaitingSpots.get_child_count()
	EventHub.connect("customer_leaving", self, "handle_leaving")
	EventHub.connect("customer_entering", self, "handle_entering")

func create_customer() -> KinematicBody2D:
	# Create and initialize new customer
	var customer : KinematicBody2D = null
	# TODO: Better way of choosing what type of customer to make
	if customers_created % 2 == 0:
		customer = preload("res://characters/customers/base_customer/customer.tscn").instance()
	else:
		customer = preload("res://characters/customers/old_lady/OldLady.tscn").instance()
	$Customers.add_child(customer)
	customer.init(navNode, next_id, rand_range(customer_wait_min, customer_wait_max))
	customer.add_to_group("dropping_off")
	
	next_id += 1
	customers_created += 1
	return customer

func send_customer(customer : KinematicBody2D) -> void:
	#all customers (new and returning) go to queue first
	queued_customers.append(customer)

func _on_WaitTimer_timeout() -> void:
	manage_queue()

func manage_queue() -> void:
	if len(waiting_customers) < max_customers and queued_customers:
		waiting_customers.append(queued_customers.pop_front())
	_move_line()

func _on_Timer_timeout() -> void:
	if queued_customers.size() > 2:
		print("not generating another customer now")
	else:
		create_and_send_customer(new_customers_on_timeout)
		$CustomerTimer.set_wait_time(rand_range(next_customer_min, next_customer_max))

func create_and_send_customer(num : int) -> void:
	for _i in range(num):
		send_customer(create_customer())
			
func reset() -> void:
	for child in $Customers.get_children():
		child.queue_free()
	waiting_customers = []
	next_id = 0
	customers_created = 0
	customers_served = 0

func start() -> void:
	create_and_send_customer(starting_customers)
	$CustomerTimer.start()
	$WaitTimer.start()
	
func restart() -> void:
	reset()
	start()
	
func stop() -> void:
	$CustomerTimer.stop()
	$WaitTimer.stop()
	queued_customers = []

func get_angry() -> void:
	for customer in waiting_customers:
		customer.storm_off()
			
func _on_Clock_new_hour(hour : int) -> void:
	if hour >= LAST_CUSTOMER_HOUR:
		$CustomerTimer.stop()
		
func _move_line() -> void:
	for i in range(len(waiting_customers)):
		waiting_customers[i].set_target_location($WaitingSpots.get_child(i).global_position)
		waiting_customers[i].decrement_patience()

func handle_leaving(customer : KinematicBody2D) -> void:
	change_customer_group(customer)
	var index = waiting_customers.find(customer)
	if index >=0:
		waiting_customers.remove(index)
		customer.set_target_location(global_position)

func handle_entering(customer : KinematicBody2D) -> void:
	change_customer_group(customer)
	send_customer(customer)
	
func change_customer_group(customer : KinematicBody2D) -> void:
	if customer.is_in_group("dropping_off"):
		customer.remove_from_group("dropping_off")
		customer.add_to_group("limbo")
	elif customer.is_in_group("limbo"):
		customer.remove_from_group("limbo")
		customer.add_to_group("picking_up")
	elif customer.is_in_group("picking_up"):
		customer.remove_from_group("picking_up")
		customer.add_to_group("satisfied_customers")
		customers_served += 1
		if customers_served >= customers_created:
			emit_signal("day_over")

func _on_Clock_almost_closing() -> void:
	get_tree().call_group("limbo", "last_call")
