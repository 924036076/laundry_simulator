extends LaundryHolder
class_name Counter
var laundry_folding = false
var cat_occupant = false


func load_laundry(laundry_in : Node2D) -> void:
	.load_laundry(laundry_in)
	print("no laundry :(")
	if laundry:
		fold_laundry()


func fold_laundry() -> void:
	print("trying to fold")
	if laundry.can_fold():
		laundry.fold()
		print("folding!")
		laundry_folding = true
		determine_interactability()
	else:
		print("laundry not foldable")


func _ready() -> void:
	._ready()
	EventHub.connect("folding_anim_completed", self, "_on_folding_anim_completed")
	EventHub.connect("occupy_object", self, "be_occupied")
	EventHub.connect("leave_object", self, "be_free")


func disallowed_action() -> void:
	$AnimationPlayer.play("shake")


func get_jump_launch_position() -> Vector2:
	return $JumpLaunch.global_position


func get_sleep_position() -> Vector2:
	return $SleepLocation.global_position


func be_occupied(id : int) -> void:
	if id == get_instance_id(): 
		cat_occupant = true
		determine_interactability()


func be_free(id : int) -> void:
	if id == get_instance_id(): 
		cat_occupant = false
		laundry_folding = false
		determine_interactability()


func determine_interactability() -> void:
	if cat_occupant or laundry_folding:
		interactable = false
	else:
		interactable = true


func _on_folding_anim_completed(folded_laundry) -> void:
	if folded_laundry == laundry:
		laundry_folding = false
		determine_interactability()
		EventHub.emit_signal("laundry_folded")


func reset() -> void:
	.reset()
	be_free(get_instance_id())


func selective_click_me(type : String):
	if laundry_folding or cat_occupant: return
	if name.to_lower() in type:
		click_me()
	else:
		$BaseAnimPlayer.play("idle")
