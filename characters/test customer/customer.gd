extends "res://characters/base_character/base_character.gd"

var return_destination : Vector2 
var register : Vector2 
var my_laundry
enum State {entering, waiting, leaving}
var current_state
var score_multiplier : int = 50
var money_label_offset = Vector2(0, -40)
var expression_offset = Vector2(0, -52)
var score : float = 0
var cleanliness_pct : float = 0
var happy_cutoff : float = 0.9
var mad_cutoff : float = 0.25

signal leaving
signal score
signal returning

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	set_physics_process(false)
	speed = 100 # TODO: have different levels of speed and remove this magic number
	my_laundry = preload("res://models/laundry/laundry.tscn").instance()
	$Bumper.load_laundry(my_laundry)
# warning-ignore:return_value_discarded
	$Bumper.connect("released", self, "drop_off")
# warning-ignore:return_value_discarded
	$Bumper.connect("returned", self, "receive_order")
	$Ticket.visible = false
	print("customer initialized and reporting for duty!")
	current_state = State.entering
	print("entering is " + str(State.entering) + " and waiting is " + str(State.waiting))


func init(node : Navigation2D, id : int, wait_time : float):
	navNode = node
	set_laundry_id(id)
	return_destination = global_position
	$Timer.set_wait_time(wait_time)

func set_laundry_id(id : int):
	if my_laundry:
		my_laundry.id = id
		$Ticket/Label.text = str(id)
	else:
		print_debug("ERROR: no laundry to give id")
	
func drop_off():
	set_physics_process(false)
	print("dropped off!")
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
	if cleanliness_pct >= happy_cutoff or cleanliness_pct < mad_cutoff:
		var expression = emote(cleanliness_pct)
		yield(expression, "animation_finished")
	show_money_earned(score, cleanliness_pct)
	leave_store()
	
func leave_store():
	print("leaving!")
	current_state = State.leaving
	set_target_location(return_destination)
	emit_signal("leaving", self)

func assess_laundry():
	print("hmmm maybe")
	if $Bumper.laundry == my_laundry:
		print("it's my order!")
		cleanliness_pct = my_laundry.assess_cleanliness()
		score = cleanliness_pct * score_multiplier
	emit_signal("score", score)
	
# warning-ignore:shadowed_variable
func show_money_earned(score : float, percent : float):
	var label = preload("res://models/money_label/MoneyLabel.tscn").instance()
	add_child(label)
	label.position = money_label_offset
	label.display("$" + str(round(score)), percent)
	
func emote(percentage):
	# May handle more than one emotion in future
	var expression = preload("res://characters/expressions/Expression.tscn").instance()
	expression.position = expression_offset
	add_child(expression)
	if percentage >= happy_cutoff:
		expression.play("happy")
	elif percentage < mad_cutoff:
		expression.play("mad")
	return expression
	
func storm_off():
	var expression = emote(0.0)
	yield(expression, "animation_finished")
	leave_store()
	
func _on_Timer_timeout():
	print("WHERE'S MY LAUNDRY??")
	emit_signal("returning", self)
	$Bumper.interactable = true

func _on_end_of_path():
	if current_state != State.leaving:
		current_state = State.waiting

