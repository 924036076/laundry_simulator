extends Node2D

export (NodePath) var up_stairs 
export (NodePath) var down_stairs

var expression_offset := Vector2(8, -83)
var money_label_offset = Vector2(0, -74)

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
	var current = $AnimationPlayer.current_animation
	if current == "appear" or current == "stairs_down": return
	if position == down_loc: return
	
	position = up_loc
	$AnimationPlayer.play("appear")
	$AudioStreamPlayer.play()
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
	$Bumper.interactable = false
	
	var expression = emote()
	yield(expression, "animation_finished")
	show_money_earned(2.0)
	yield(get_tree().create_timer(buffer), "timeout")
	go_upstairs()


func show_money_earned(money : float, percent : float = 1) -> void:
	var label = preload("res://models/money_label/money_label.tscn").instance()
	add_child(label)
	label.position = money_label_offset
	label.display("$" + str(round(money)), percent)
	EventHub.emit_signal("add_money", money)


func emote() -> AnimatedSprite:
	var expression = preload("res://characters/emote/emote.tscn").instance()
	expression.position = expression_offset
	add_child(expression)
	expression.set_and_play(1)
	return expression


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
			$AudioStreamPlayer.play()
		"stairs_down":
			$Bumper.interactable = true
			$Timer.start()
		_:
			pass


func _on_Timer_timeout():
	if $Bumper.interactable:
		$Bumper.click_me()


func _on_Tween_tween_all_completed():
	if position == up_loc:
		position = Vector2(0,0)
