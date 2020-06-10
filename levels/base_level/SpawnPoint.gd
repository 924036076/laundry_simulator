extends Node2D

var navNode : Navigation2D 
var register : Vector2 
var player : KinematicBody2D
var next_id : int = 0

var LAST_CUSTOMER_HOUR : int = 16

func set_register(position : Vector2):
	register = position
	print("I've got a destination to tell the customers now!")

func init(node : Navigation2D, destination : Vector2, body : KinematicBody2D):
	navNode = node
	register = destination
	player = body

func send_customer():
	var customer = preload("res://characters/test customer/customer.tscn").instance()
	customer.set_nav_node(navNode)
	customer.connect("leaving", self, "_move_line")
	customer.get_node("Bumper").connect("click", player, "_on_Interactable_click")
	customer.connect("score", get_parent().get_node("Events"), "update_score")
	customer.set_return_destination(global_position)
	$Customers.add_child(customer)
	customer.set_id(next_id)
	customer.send_off(register)
	next_id += 1

func _on_Timer_timeout():
	send_customer()
	
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
