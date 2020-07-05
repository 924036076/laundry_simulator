extends "res://characters/base_character/base_character.gd"

var return_destination : Vector2 
var register : Vector2 
var my_laundry : Node2D
var score_multiplier := 50
var expression_offset := Vector2(0, -52)
var buff_offset := Vector2(0, 15)
var score := 0.0
var cleanliness_pct := 0.0
const FURIOUS := 0.0
var patience := 1.2
var patience_unit := 0.02
var patience_lower_cutoff := 0.2
var patience_upper_cutoff := 0.6
var happy_buff_cutoff := 1.15
var received_laundry := false

signal leaving
signal returning

func _ready() -> void:
	._ready()
	set_physics_process(false)
	speed = 100 # TODO: have different levels of speed and remove this magic number
	my_laundry = preload("res://models/laundry/laundry.tscn").instance()
	$Bumper.load_laundry(my_laundry)
	$Bumper/HandPos/Ticket.visible = false
	animationState = $AnimationTree["parameters/playback"]
	assert($AnimationTree.active == true, "Customer's Animation Tree is not active")
	EventHub.connect("patience_cloud", self, "on_patience_cloud")

func init(node : Navigation2D, id : int, wait_time : float) -> void:
	navNode = node
	set_laundry_id(id)
	return_destination = global_position
	$Timer.set_wait_time(wait_time)

func set_laundry_id(id : int) -> void:
	if my_laundry:
		my_laundry.id = id
		$Bumper/HandPos/Ticket/Label.text = str(id)
	else:
		print_debug("ERROR: no laundry to give id")
	
func drop_off() -> void:
	set_physics_process(false)
	$Bumper.interactable = false
	$Bumper/HandPos/Ticket.visible = true
	my_laundry.show_ticket()
	$Timer.start()	
	leave_store()
	
func receive_order() -> void:
	$Bumper.interactable = false
	$Bumper/HandPos/Ticket.visible = false
	assess_laundry()
	var expression = emote(cleanliness_pct)
	# TODO: work on scoring and cleaniness pct logic to be better; redo this
	if patience >= happy_buff_cutoff and cleanliness_pct >= 1: happy_buff()
	yield(expression, "animation_finished")
	show_money_earned(score, cleanliness_pct)
	received_laundry = true
	leave_store()
	
func happy_buff() -> void:
	# To be overridden by inherited customers
	print("happy buff!")
	
func leave_store() -> void:
	set_target_location(return_destination)
	EventHub.emit_signal("customer_leaving", self)

func assess_laundry() -> void:
	if $Bumper.laundry == my_laundry:
		cleanliness_pct = my_laundry.assess_cleanliness()
		score = cleanliness_pct * score_multiplier * patience
	stop_patience_particles()
	
func emote(happiness_pct: float) -> AnimatedSprite:
	var expression = preload("res://characters/expressions/Expression.tscn").instance()
	expression.position = expression_offset
	add_child(expression)
	expression.set_and_play(happiness_pct)
	return expression
	
func storm_off() -> void:
	stop_patience_particles()
	if score == 0:
		var expression = emote(FURIOUS)
		yield(expression, "animation_finished")
	leave_store()
	
func _on_Timer_timeout() -> void:
	back_to_store()
	
func back_to_store() -> void:
	EventHub.emit_signal("customer_entering", self)
	$Bumper.interactable = true
	$Bumper.set_state_pickup()
	
func last_call() -> void:
	$Timer.stop()
	back_to_store()

func decrement_patience() -> void:
	if received_laundry: return
	patience -= patience_unit 
	if patience < patience_upper_cutoff:
		$PatienceParticles.emitting = true
	if patience < patience_lower_cutoff:
		$PatienceParticles.set_param(CPUParticles2D.PARAM_SCALE, 2)
		$PatienceParticles.set_param(CPUParticles2D.PARAM_ANIM_SPEED, 2)
	if patience <= 0:
		storm_off()

func stop_patience_particles() -> void:
	$PatienceParticles.emitting = false
	$PatienceParticles.visible = false

func _on_Bumper_disallowed_customer_action() -> void:
	$AnimationPlayer.play("shake")
	
func _on_end_of_path() -> void:
	._on_end_of_path()
	if global_position.distance_to(return_destination) <= 0.25 and received_laundry:
		queue_free()

func _on_Bumper_modulate(modulation : Color) -> void:
	$Sprite.modulate = modulation
	
func add_patience_points(points : int) -> void:
	patience += points * patience_unit
	
func on_patience_cloud(cloud : Area2D, points : int) -> void:
	if !cloud.overlaps_area($Bumper): return
	if received_laundry: return
	add_patience_points(points)
	var patience_point = preload("res://characters/customers/effects/patience_change/PatiencePoint.tscn").instance()
	call_deferred("add_child", patience_point)
