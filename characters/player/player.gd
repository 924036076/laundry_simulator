extends "res://characters/base_character/base_character.gd"

var enabled : bool = false

func interact(body):
	# unallowed to interact scenarios
	# either body is not interactable, or it can only give and the player's hands are full
	if !body.interactable or (body.can_give and !body.can_receive and laundry):  
		$UnallowedSoundPlayer.play()
		body.disallowed_action()
	else:	# allowed to interact: swap laundry loads
		$TransferSoundPlayer.play()
		var player_laundry = null
		var object_laundry = null
		if body.can_receive:
			player_laundry = unload_laundry()
		if body.can_give and !laundry:
			object_laundry = body.unload_laundry()
		load_laundry(object_laundry)
		body.load_laundry(player_laundry)
	
	target_objct.set_target(false)
	target_objct = null
	set_target_location(global_position) #stop moving once interact

func unload_laundry():
	if !laundry:
		return null
	var laundry_out = laundry
	remove_child(laundry)
	laundry = null
	return laundry_out
	
func load_laundry(laundry_in):
	if !laundry_in:
		return
	laundry = laundry_in
	laundry.position = offset
	add_child(laundry)
	
func set_targetobjct(body : Area2D):
	if target_objct:
		target_objct.set_target(false)
	target_objct = body
	if body:
		body.set_target(true)
		
func _on_Interactable_click(body):
	if !enabled:
		return

	set_targetobjct(body)
	if target_objct.player_in_range:
		interact(target_objct)	
	else:
		var distance = global_position.distance_to(target_objct.global_position)
		var new_target = target_objct.global_position.linear_interpolate(global_position, target_objct.radius/distance)
		set_target_location(new_target)
		
func set_target_location(destination : Vector2):
	if enabled:
		.set_target_location(destination)
		
func enable(input : bool):
	enabled = input
	
func reset():
	if laundry:
		laundry.queue_free()
		laundry = null
	if target_objct:
		target_objct.set_target(false)
		target_objct = null

