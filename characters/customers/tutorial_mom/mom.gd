extends Node2D

export (NodePath) var up_stairs 
export (NodePath) var down_stairs

var up_loc
var down_loc

var buffer = 0.3


func _ready():
	var laundry = preload("res://models/laundry/laundry.tscn").instance()
	$Bumper.load_laundry(laundry)
	$Bumper.interactable = false
	visible = false
	
	if up_stairs:
		var up_node = get_node(up_stairs)
		up_loc = up_node.position
	if down_stairs:
		var down_node = get_node(down_stairs)
		down_loc = down_node.position


func retrieve_laundry():
	go_downstairs()
	$Bumper.set_state_pickup()


func go_downstairs():
	position = up_loc
	$AnimationPlayer.play("appear")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("stairs_down")
	walk(up_loc, down_loc, $AnimationPlayer.get_animation("stairs_down").length)


func go_upstairs():
	yield(get_tree().create_timer(buffer), "timeout")
	$AnimationPlayer.play("stairs_up")
	walk(down_loc, up_loc, $AnimationPlayer.get_animation("stairs_up").length)


func walk(origin, destination, length):
	$Tween.interpolate_property(self, "position", origin, destination, length + buffer, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	visible = true


func _on_Bumper_released():
	go_upstairs()
	$Bumper.interactable = false


func _on_Bumper_returned():
	# TODO: emote and give money
	go_upstairs()
	$Bumper.interactable = false


func _on_Bumper_disallowed_customer_action():
	if $AnimationPlayer.is_playing() and $AnimationPlayer.current_animation != "shake":
		return
	$AnimationPlayer.play("shake")


func _on_Bumper_modulate(modulation : Color) -> void:
	$Sprite.modulate = modulation


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"stairs_up":
			$AnimationPlayer.play_backwards("appear")
		"stairs_down":
			$Bumper.interactable = true
			$Timer.start()
		_:
			pass


func _on_Timer_timeout():
	if $Bumper.interactable:
		$Bumper.click_me()
