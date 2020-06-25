extends "res://characters/base_character/base_character.gd"

export (NodePath) var patrol_path
export (NodePath) var desk_path

var desk : Node2D
var patrol_points
var patrol_index = 0
var rng = RandomNumberGenerator.new()
signal mischief

func _ready():
	animated = true #in the future all characters will be animated, just not now
	animationState = $AnimationTree["parameters/playback"]
	speed = 100
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
		#set_target_location(patrol_points[patrol_index])
	if desk_path:
		desk = get_node(desk_path)
	office_work()
	
func office_work():
	set_target_location(desk.global_position)

func _on_end_of_path():
	._on_end_of_path()
	$WaitTimer.start(rng.randi_range(3, 10))
	print("cat reached end of path")
	animationState.travel("working")
		
func _on_WaitTimer_timeout():
	animationState.travel("Idle")
	print("wait timer timeout")
	if animationState.get_current_node() == "Idle":
		emit_signal("mischief")
		random_patrol_destination()
	else:
		$WaitTimer.start(1)
		
func random_patrol_destination():
	patrol_index = rng.randi_range(0,  patrol_points.size()-1)
	print("patrol index: ", patrol_index)
	set_target_location(patrol_points[patrol_index])
