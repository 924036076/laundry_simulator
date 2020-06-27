extends Node2D

var wet = false
var dirty = true
var bloody = false
var soiled = false
var hairy = false
var washable_modulation = Color(0.67, 0.67, 0.67)
var dryable_modulation = Color(0.85, 0.85, 0.85)
var default_modulation = Color(1, 1, 1)
var starting_cleanliness : float = 1
var highest_unfinished_score : float = 0.25
enum size {small, medium, large} #TODO: something with size
var id : int

# Called when the node enters the scene tree for the first time.
func _ready():
	update_visuals()
	starting_cleanliness = assess_cleanliness()

func can_wash():
	return dirty or hairy
	
func can_dry():
	return wet
	
func hairify():
	hairy = true
	update_visuals()
	
func dehairify():
	hairy = false
	update_visuals()
	
func wash():
	dirty = false
	wet = true
	update_visuals()
	
func dry():
	wet = false
	update_visuals()
	
func update_visuals():
	update_modulation()
	update_particles()

func update_modulation():	
	if can_wash():
		$Sprite.modulate = washable_modulation
	elif can_dry():
		$Sprite.modulate = dryable_modulation
	else:
		$Sprite.modulate = default_modulation

func update_particles():
	# Updates particle effects with appropriate class variable booleans
	# Emitting changes whether particles are produced, visible whether they're visible
	# Only changing emitting results in lingering particles being visible after a state change

	$"Dirt Particles".emitting = dirty
	$"Dirt Particles".visible = dirty
	$"Drip Particles".emitting = wet
	$"Drip Particles".visible = wet
	$"Hair Particles".emitting = hairy
	$"Hair Particles".visible = hairy
	
func assess_cleanliness() -> float:
	var conditions = [wet, dirty, bloody, soiled, hairy]
	var max_score : int = conditions.size()
	var score : float = 0.0
	
	for state in conditions:
		if !state: score += 1
	var cleanliness = score/max_score
	if cleanliness < 1:
		cleanliness = min(cleanliness, highest_unfinished_score)
	return cleanliness
	
func score_laundry() -> float:
	# TODO: integrate laundry scoring function to only give money when clothes
	# are better off than they started
	var score : float = 0.0
	var current_cleanliness = assess_cleanliness()
	if current_cleanliness > starting_cleanliness:
		score = current_cleanliness - starting_cleanliness
	return score
	
func show_ticket():
	$Ticket/Label.text = str(id)
	$Ticket.visible = true
	
	


