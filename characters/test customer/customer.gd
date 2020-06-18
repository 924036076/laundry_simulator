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
var FURIOUS : float = 0.0
var patience : float = 1.2
var patience_unit : float = 0.02
var patience_lower_cutoff : float = 0.2
var patience_upper_cutoff : float = 0.6

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
	if $Bumper.laundry == my_laundry:
		cleanliness_pct = my_laundry.assess_cleanliness()
		score = cleanliness_pct * score_multiplier * patience
		print("patrience: ", patience)
	stop_patience_particles()
	emit_signal("score", score)
	
# warning-ignore:shadowed_variable
func show_money_earned(score : float, percent : float):
	var label = preload("res://models/money_label/MoneyLabel.tscn").instance()
	add_child(label)
	label.position = money_label_offset
	label.display("$" + str(round(score)), percent)
	
func emote(happiness_pct: float):
	var expression = preload("res://characters/expressions/Expression.tscn").instance()
	expression.position = expression_offset
	add_child(expression)
	expression.set_and_play(happiness_pct)
	return expression
	
func storm_off():
	stop_patience_particles()
	var expression = emote(FURIOUS)
	yield(expression, "animation_finished")
	leave_store()
	
func _on_Timer_timeout():
	print("WHERE'S MY LAUNDRY??")
	emit_signal("returning", self)
	$Bumper.interactable = true

func _on_end_of_path():
	if current_state != State.leaving:
		current_state = State.waiting

func decrement_patience():
	patience -= patience_unit
	if patience < patience_upper_cutoff:
		$PatienceParticles.emitting = true
		if patience < patience_lower_cutoff:
			$PatienceParticles.set_param(CPUParticles2D.PARAM_SCALE, 2)
			$PatienceParticles.set_param(CPUParticles2D.PARAM_ANIM_SPEED, 2)
			if patience <= 0:
				storm_off()

func stop_patience_particles():
	$PatienceParticles.emitting = false
	$PatienceParticles.visible = false
	patience = 5
