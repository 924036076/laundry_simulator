extends Node2D

var wet = false
var dirty = true
var bloody = false
var soiled = false
var highest_unfinished_score : float = 0.25
enum size {small, medium, large} #TODO: something with size
var id : int

# Called when the node enters the scene tree for the first time.
func _ready():
	update_particles()

func can_wash():
	return dirty
	
func can_dry():
	return wet
	
func wash():
	dirty = false
	wet = true
	update_particles()
	
func dry():
	wet = false
	update_particles()
	
func update_particles():
	# Updates particle effects with appropriate class variable booleans
	# Emitting changes whether particles are produced, visible whether they're visible
	# Only changing emitting results in lingering particles being visible after a state change

	$"Dirt Particles".emitting = dirty
	$"Dirt Particles".visible = dirty
	$"Drip Particles".emitting = wet
	$"Drip Particles".visible = wet
	
func assess_cleanliness() -> float:
	var conditions = [wet, dirty, bloody, soiled]
	var max_score : int = conditions.size()
	var score : float = 0.0
	
	for state in conditions:
		if !state: score += 1
		print(state)
	var cleanliness = score/max_score
	if cleanliness < 1:
		cleanliness = min(cleanliness, highest_unfinished_score)
	return cleanliness
	
func show_ticket():
	$Ticket/Label.text = str(id)
	$Ticket.visible = true
	
	


