extends KinematicBody2D

var offset = Vector2(50, 0) # where the laundry goes
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
	if !navNode:
		navNode = get_node(navNodePath)
	print("base character nav initialization")
	print(navNode)
	
func _physics_process(delta: float) -> void:
	move_along_path(speed*delta)
	
func move_along_path(distance : float) -> void:
	var start_point : = global_position

	while path.size():
		var distance_to_next : = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			var move_rotation = get_angle_to(path[0])
			var motion = Vector2(speed,0).rotated(move_rotation)
			if motion.x > 0:
				$Sprite.flip_h = true
			else:
				$Sprite.flip_h = false
# warning-ignore:return_value_discarded
			move_and_slide(motion)
			break
		elif path.size() == 1 && distance > distance_to_next:
			#position = path[0]
			
			set_physics_process(false)
			print('reached the end')
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
		print('loop iteration')
		
func set_target_location(new_target : Vector2) -> void:
	print("new target!")
	target = new_target
	print(navNode)
	path = navNode.get_simple_path(global_position, new_target)
	if path.size() == 0:
		print("you sent me an empty array!")
		return
	set_physics_process(true)
