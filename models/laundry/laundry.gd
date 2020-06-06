extends Node2D

var wet = false
var dirty = true
var bloody = false
var soiled = false
enum size {small, medium, large} #TODO: something with size

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
	print("setting particles")
	$"Dirt Particles".emitting = dirty
	$"Drip Particles".emitting = wet
	


