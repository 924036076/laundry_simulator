extends KinematicBody2D

var offset = Vector2(50, 0)
var target_objct = null
var target = Vector2()
var velocity = Vector2()
var laundry = null

var navNode
var path : = PoolVector2Array() 
var speed : = 150
export(NodePath) var navNodePath

func _ready() -> void:
	set_physics_process(false)
	print(navNodePath)
	navNode = get_node(navNodePath)
	print(navNode)
	
func _physics_process(delta: float) -> void:
	move_along_path(speed*delta)
	
func move_along_path(distance : float) -> void:
	var start_point : = global_position

	for _i in range(path.size()):
		var distance_to_next : = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			var move_rotation = get_angle_to(path[0])
			var motion = Vector2(speed,0).rotated(move_rotation)
			move_and_slide(motion)
			break
		elif path.size() == 1 && distance > distance_to_next:
			position = path[0]
			set_physics_process(false)
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
		
func set_path(new_target : Vector2) -> void:
	target = new_target
	path = navNode.get_simple_path(global_position, new_target)
	if path.size() == 0:
		print("you sent me an empty array!")
		return
	set_physics_process(true)

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
		set_path(new_target)
