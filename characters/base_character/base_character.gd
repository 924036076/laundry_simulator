extends KinematicBody2D
class_name BaseCharacter

var laundry_offset = Vector2(50, 0) 
var money_label_offset = Vector2(0, -74)
var target_objct : Area2D = null
var target := Vector2()
var laundry : Node2D = null
var animationState : AnimationNodeStateMachinePlayback

var navNode : Navigation2D
var path := PoolVector2Array() 
var speed := 175
var walking := false
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
		var distance_to_next := start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			var move_rotation = get_angle_to(path[0])
			var velocity = Vector2(speed,0).rotated(move_rotation)
			velocity = move_and_slide(velocity)
			update_sprite(velocity)
			break
		elif path.size() == 1 && distance > distance_to_next:
			set_physics_process(false)
			emit_signal("end_of_path")
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

func update_sprite(velocity : Vector2):
	var direction = velocity.normalized()
	$AnimationTree.set("parameters/Idle/blend_position", direction)
	$AnimationTree.set("parameters/Move/blend_position", direction)
	animationState.travel("Move")

func set_target_location(new_target : Vector2) -> void:
	if new_target.distance_to(global_position) < 2: 
		_on_end_of_path()
		return
	walking = true
	target = new_target
	path = navNode.get_simple_path(global_position, new_target, true)
	if path.size() == 0:
		print("you sent me an empty array!")
		return
	set_physics_process(true)

func _on_end_of_path() -> void:
	walking = false
	set_physics_process(false)
	animationState.travel("Idle")
		
func show_money_earned(money : float, percent : float = 1) -> void:
	var label = preload("res://models/money_label/money_label.tscn").instance()
	add_child(label)
	label.position = money_label_offset
	label.display("$" + str(round(money)), percent)
	EventHub.emit_signal("add_money", money)
