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

func _ready() -> void:
	update_visuals()
	starting_cleanliness = assess_cleanliness()

func can_wash() -> bool:
	return dirty or hairy
	
func can_dry() -> bool:
	return wet
	
func hairify() -> void:
	hairy = true
	update_visuals()
	
func dehairify() -> void:
	hairy = false
	update_visuals()
	
func wash() -> void:
	dirty = false
	wet = true
	update_visuals()
	
func dry() -> void:
	wet = false
	update_visuals()
	
func update_visuals() -> void:
	update_modulation()
	update_particles()

func update_modulation() -> void:	
	if can_wash():
		$Sprite.modulate = washable_modulation
	elif can_dry():
		$Sprite.modulate = dryable_modulation
	else:
		$Sprite.modulate = default_modulation

func update_particles() -> void:
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
	# TODO: Better laundry scoring
	# (Currently doesn't make sense if more variables are introduced in gameplay)
	var score : float = 0.0
	var current_cleanliness = assess_cleanliness()
	if current_cleanliness > starting_cleanliness:
		score = current_cleanliness - starting_cleanliness
	return score
	
func show_ticket() -> void:
	$Ticket/Label.text = str(id)
	$Ticket.visible = true


