extends "res://characters/base_character/base_character.gd"

func interact(body, objct_laundry_bool):
	print("time to make some decisions")
	if !laundry and objct_laundry_bool:  
		print("mine now!")
		laundry = body.unload_laundry()
		laundry.position = offset
		add_child(laundry)
	elif laundry and !objct_laundry_bool:
		print("take it! it smells")
		remove_child(laundry)
		body.load_laundry(laundry)
		laundry = null
	target_objct.set_target(false)
	target_objct = null
	set_target_location(global_position) #stop moving once interact
		
func _on_Interactable_click(body):
	print("got your signal " + str(body.get_name()))
	if target_objct:
		target_objct.set_target(false)
	body.set_target(true)
	target_objct = body
	if target_objct.player_in_range and target_objct.interactable:
		interact(target_objct, target_objct.laundry_available)
	else:
		var distance = global_position.distance_to(target_objct.global_position)
		var new_target = target_objct.global_position.linear_interpolate(global_position, target_objct.radius/distance)
		set_target_location(new_target)
