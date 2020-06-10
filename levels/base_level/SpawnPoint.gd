extends Node2D

var navNode : Navigation2D 
var register : Vector2 
var player : KinematicBody2D
var next_id : int = 0


func set_register(position : Vector2):
	register = position
	print("I've got a destination to tell the customers now!")

func init(node : Navigation2D, destination : Vector2, body : KinematicBody2D):
	navNode = node
	register = destination
	player = body
	send_customer()

func send_customer():
	var customer = preload("res://characters/test customer/customer.tscn").instance()
	customer.set_nav_node(navNode)
	customer.get_node("Area2D").connect("click", player, "_on_Interactable_click")
	customer.set_return_destination(global_position)
	add_child(customer)
	customer.set_id(next_id)
	customer.send_off(register)
	next_id += 1

	
