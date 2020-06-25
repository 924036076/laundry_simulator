extends Area2D

var default_modulation = Color(1,1,1,1)
var selected_modulation = Color(1,1,0.5,1)
var is_target = false setget set_target
var laundry = null
var interactable = true
var can_give = true
var can_receive = true
var laundry_available = false
var player_in_range = false
var mouse_over = false
var radius = 0.0
var offset = Vector2(0,0)

signal click

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect("mouse_entered", self, "_mouse_over", [true])
	#connect("mouse_exited", self, "_mouse_over", [false])
	_calculate_radius()

func _calculate_radius():
	# Default method for calculating interaction radius for rectangular interactables
	# Should be overridden for any interactables with circular colliders
	var extents =  get_node("CollisionShape2D").shape.get_extents()
	# Halving the smallest extent by two for better controlability/look
	# (Otherwise player will interact with object far away / in odd corners)
	radius = min(extents.x, extents.y)/2

func _on_Interactable_body_entered(body):
	if body.get_name() == "Player":
		player_in_range = true
		if is_target:
			body.interact(self)
			
func _on_Interactable_body_exited(body):
	if body.get_name() == "Player":
		player_in_range = false
	
func load_laundry(laundry_in):
	if !laundry_in:
		return
	laundry = laundry_in
	add_child(laundry)
	laundry_available = true
	laundry.position = offset

func unload_laundry():
	if !laundry:
		return null
	var laundry_to_give = laundry
	remove_child(laundry)
	laundry = null
	laundry_available = false
	return laundry_to_give

func _mouse_over(over):
	self.mouse_over = over

func _unhandled_input(event):
	if mouse_over and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		get_tree().set_input_as_handled()
		emit_signal("click", self)
		
func set_target(boolean):
	is_target = boolean
	if is_target:
		$Sprite.modulate = selected_modulation
	else:
		$Sprite.modulate = default_modulation
		
func reset():
	if laundry:
		laundry.queue_free()
	laundry = null
	laundry_available = false
	
func disallowed_action():
	pass

func _on_mouse_entered():
	mouse_over = true

func _on_mouse_exited():
	mouse_over = false
