extends Area2D

var default_modulation = Color(1, 1, 1, 1)
var selected_modulation = Color(0.83, 1, 0.89, 1)
var is_target = false setget set_target
var laundry = null
var interactable = true setget set_interactable
var can_give = true
var can_receive = true
var laundry_available = false
var player_in_range = false
var cat_in_range = false
var mouse_over = false
var radius = 0.0
var offset = Vector2(0,0)

signal click

func _ready() -> void:
	_calculate_radius()

func _calculate_radius() -> void:
	# Default method for calculating interaction radius for rectangular interactables
	# Overridden for any interactables with circular colliders
	
	var extents =  get_node("CollisionShape2D").shape.get_extents()
	# Halving the smallest extent by two for better controlability/feel
	radius = min(extents.x, extents.y)/2

func _on_Interactable_body_entered(body : PhysicsBody2D) -> void:
	if body.get_name() == "Player":
		player_in_range = true
		if is_target: body.interact(self) # TODO: make objects and player less tightly coupled
	if body.get_name() == "Cat":
		cat_in_range = true
			
func _on_Interactable_body_exited(body : PhysicsBody2D) -> void:
	if body.get_name() == "Player":
		player_in_range = false
	if body.get_name() == "Cat":
		cat_in_range = false
	
func load_laundry(laundry_in : Node2D) -> void:
	if !laundry_in: return
	
	laundry = laundry_in
	add_child(laundry)
	laundry_available = true
	laundry.position = offset

func unload_laundry() -> Node2D:
	if !laundry: return null
	
	var laundry_to_give = laundry
	remove_child(laundry)
	laundry = null
	laundry_available = false
	return laundry_to_give

func _mouse_over(over : bool) -> void:
	self.mouse_over = over

func _unhandled_input(event) -> void:
	# TODO: refactor to enable mobile controls
	if !mouse_over: return
	if not event is InputEventMouseButton: return
	if event.button_index != BUTTON_LEFT: return
	if not event.is_pressed(): return
	
	get_tree().set_input_as_handled()
	emit_signal("click", self)
		
func set_target(boolean) -> void:
	is_target = boolean
	modulate()
		
func reset() -> void:
	if laundry:
		laundry.queue_free()
	laundry = null
	laundry_available = false
	
func disallowed_action() -> void:
	# Overriden by scenes that inherit
	pass

func modulate() -> void:
	if is_target or mouse_over and interactable:
		$Sprite.modulate = selected_modulation
	else:
		$Sprite.modulate = default_modulation

func _on_mouse_entered() -> void:
	mouse_over = true
	modulate()
	
func _on_mouse_exited() -> void:
	mouse_over = false
	modulate()
	
func set_interactable(boolean) -> void:
	interactable = boolean
	modulate()
