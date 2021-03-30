extends Node2D

var navNode : Navigation2D 
var player : KinematicBody2D
const NEXT_CUSTOMER_MAX := 20.0
var next_id := 0
var next_customer_min := 3.0
var next_customer_max := NEXT_CUSTOMER_MAX
var customer_wait_min := 20.0
var customer_wait_max := 32.0
var queued_customers := []
var waiting_customers := []
var max_waiting_customers : int
var max_customers := 6
var starting_customers := 1
var new_customers_on_timeout := 1
var customers_created := 0
var customers_served := 0
var ratings_count := 0
var rating_sum := 0.0
const LAST_CUSTOMER_HOUR := 16 # TODO: have this connected to clock then send signal


func _ready():
	EventHub.connect("new_game", self, "_on_new_game")
	EventHub.connect("day_over", self, "_on_day_over")
	EventHub.connect("game_over", self, "_on_game_over")
	EventHub.connect("restart", self, "_on_restart")
	EventHub.connect("new_day", self, "_on_new_day")
	print("in spawner ready function")


func init(node : Navigation2D, body : KinematicBody2D) -> void:
	navNode = node
	player = body
	max_waiting_customers = $WaitingSpots.get_child_count()
	EventHub.connect("customer_leaving", self, "handle_leaving")
	EventHub.connect("customer_entering", self, "handle_entering")
	EventHub.connect("new_rating", self, "_on_new_rating")
	print("spawner initialized")


func create_customer() -> KinematicBody2D:
	# Create and initialize new customer
	var customer : KinematicBody2D = null
	# TODO: Better way of choosing what type of customer to make
	match customers_created % 3:
		0:
			customer = preload("res://characters/customers/old_lady/old_lady.tscn").instance()
		1:
			customer = preload("res://characters/customers/base_customer/customer.tscn").instance()
		2: 
			customer = preload("res://characters/customers/young_man/young_man.tscn").instance()

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
	call_deferred("manage_queue")


func manage_queue() -> void:
	if len(waiting_customers) < max_waiting_customers and queued_customers:
		waiting_customers.append(queued_customers.pop_front())
	call_deferred("_move_line")


func _on_Timer_timeout() -> void:
	if queued_customers.size() >= 2 or next_id >= max_customers:
		print("not generating another customer now")
	else:
		create_and_send_customer(new_customers_on_timeout)
		$CustomerTimer.set_wait_time(rand_range(next_customer_min, next_customer_max))


func _on_new_rating(score : float) -> void:
	ratings_count += 1
	rating_sum += score
	print("new score received: ", score)
	print("total ratings so far: ", ratings_count)


func create_and_send_customer(num : int) -> void:
	for _i in range(num):
		var customer = create_customer()
		call_deferred("send_customer", customer)


func reset() -> void:
	print("spawner resetting")
	adjust_difficulty()
	for child in $Customers.get_children():
		child.queue_free()
	
	waiting_customers = []
	queued_customers = []
	next_id = 0
	customers_created = 0
	customers_served = 0


func _on_new_game() -> void:
	next_customer_max = NEXT_CUSTOMER_MAX
	start()
	# TODO: do same re-anchoring for max_customers

func start() -> void:
	create_and_send_customer(starting_customers)
	$CustomerTimer.start()
	$WaitTimer.start()


func restart() -> void:
	reset()
	call_deferred("start")
	print("next customer max time now: ", next_customer_max)
	print("max customers now: ", max_customers)
	
	
func stop() -> void:
	$CustomerTimer.stop()
	$WaitTimer.stop()
	queued_customers = []


func adjust_difficulty() -> void:
	print("adjusting difficulty")
	if ratings_count == 0:
		print("nevermind! Already did or at default")
		return
		
	var average_score = rating_sum / ratings_count
	print("average score: ", average_score)
	
	if average_score > 1.1:
		max_customers = ratings_count + 3
		next_customer_max = max(4, next_customer_max - 3)
	elif average_score > 1.0:
		max_customers = ratings_count + 2
		next_customer_max = max(4, next_customer_max - 2)
	elif average_score > 0.9:
		max_customers = ratings_count + 1
	elif average_score < 0.75:
		max_customers = ratings_count - 1
	elif average_score < 0.5:
		max_customers = ratings_count - 2
		next_customer_max += 2
	elif average_score <= 0.25:
		max_customers = max(ratings_count - 4, 2)
		next_customer_max = min(30, next_customer_max + 4)
	
	ratings_count = 0
	rating_sum = 0


func get_angry() -> void:
	for customer in waiting_customers:
		customer.storm_off()
	waiting_customers = []


func _on_Clock_new_hour(hour : int) -> void:
	if hour >= LAST_CUSTOMER_HOUR:
		$CustomerTimer.stop()


func _move_line() -> void:
	var i = 0
	while i < len(waiting_customers):
		waiting_customers[i].set_target_location($WaitingSpots.get_child(i).global_position)
		waiting_customers[i].decrement_patience()
		i += 1


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
			EventHub.emit_signal("day_over")


func _on_Clock_almost_closing() -> void:
	get_tree().call_group("limbo", "last_call")


func _on_day_over():
	get_angry()
	stop()


func _on_game_over():
	get_angry()
	stop()

func _on_restart():
	stop()
	reset()

func _on_new_day():
	print("spawner new day called")
	restart()

