extends KinematicBody2D

var laundry_offset = Vector2(50, 0) 
var money_label_offset = Vector2(0, -40)
var target_objct = null
var target = Vector2()
var laundry = null
var animated = false
var animationState : AnimationNodeStateMachinePlayback

var navNode
var path : = PoolVector2Array() 
var speed : = 175
export(NodePath) var navNodePath
signal end_of_path
signal score

func _ready() -> void:
	set_physics_process(false)
	if !navNode and navNodePath:
		navNode = get_node(navNodePath)
	
func _physics_process(delta: float) -> void:
	move_along_path(speed*delta)
	
func move_along_path(distance : float) -> void:
	var start_point : = global_position

	while path.size():
		var distance_to_next : = start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			var move_rotation = get_angle_to(path[0])
			var velocity = Vector2(speed,0).rotated(move_rotation)
			update_sprite(velocity)
# warning-ignore:return_value_discarded
			move_and_slide(velocity)
			break
		elif path.size() == 1 && distance > distance_to_next:
			set_physics_process(false)
			emit_signal("end_of_path")
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

func update_sprite(velocity : Vector2):
	if !animated:
		if velocity.x > 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
		return
	var direction = velocity.normalized()
	$AnimationTree.set("parameters/Idle/blend_position", direction)
	$AnimationTree.set("parameters/Move/blend_position", direction)
	animationState.travel("Move")

func set_target_location(new_target : Vector2) -> void:
	target = new_target
	path = navNode.get_simple_path(global_position, new_target)
	if path.size() == 0:
		print("you sent me an empty array!")
		return
	set_physics_process(true)

func _on_end_of_path() -> void:
	set_physics_process(false)
	if animated:
		animationState.travel("Idle")
		
func show_money_earned(money : float, percent : float = 1) -> void:
	var label = preload("res://models/money_label/MoneyLabel.tscn").instance()
	add_child(label)
	label.position = money_label_offset
	label.display("$" + str(round(money)), percent)
	emit_signal("score", money)
