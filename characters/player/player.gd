extends BaseCharacter
class_name Player

var movement_enabled : bool = false

func _ready() -> void:
	laundry_offset = Vector2(0, -1)
	animationState = $AnimationTree["parameters/playback"]
	assert($AnimationTree.active == true, "player's Animation Tree is not active")
	EventHub.connect("click", self, "_on_Interactable_click")
	
func interact(body) -> void:
	# Reset target object and stop moving
	set_targetobjct(null)
	set_target_location(global_position)
	
	# Either body is not interactable, or it can only give and player cannot receive
	if !body.interactable or (body.can_give and !body.can_receive and laundry):  
		$UnallowedSoundPlayer.play()
		body.disallowed_action()
	else:	# Allowed to interact: swap laundry loads
		$TransferSoundPlayer.play()
		var player_laundry : = null if !body.can_receive else unload_laundry()
		var object_laundry = null
		if body.can_give and !laundry:
			object_laundry = body.unload_laundry()
		load_laundry(object_laundry)
		body.load_laundry(player_laundry)

func unload_laundry() -> Node2D:
	if !laundry: return null
	
	var laundry_out = laundry
	$laundry_pos.remove_child(laundry)
	laundry = null
	return laundry_out
	
func load_laundry(laundry_in : Node2D) -> void:
	if laundry_in == null: return
	
	laundry = laundry_in
	$laundry_pos.call_deferred("add_child", laundry)
	laundry.position = laundry_offset
	
func set_targetobjct(objct : Area2D) -> void:
	if target_objct: target_objct.set_target(false)
	
	target_objct = objct
	if !objct: return
	objct.set_target(true)
		
func _on_Interactable_click(objct) -> void:
	if !movement_enabled: return
	set_targetobjct(objct)
	# New target object is in range
	if target_objct.overlaps_area($Area2D): 
		interact(target_objct)
		return

	# Player must travel to new target object
	var distance := global_position.distance_to(target_objct.global_position)
	var new_target := target_objct.global_position.linear_interpolate(global_position, target_objct.radius/distance)
	set_target_location(new_target)
		
func set_target_location(destination : Vector2) -> void:
	if movement_enabled: 
		.set_target_location(destination)
	
func enable_movement(input : bool) -> void:
	movement_enabled = input
	
func reset() -> void:
	if laundry:
		laundry.queue_free()
		laundry = null
	set_targetobjct(null)

func _on_Area2D_area_entered(area):
	if area == target_objct:
		interact(target_objct)
