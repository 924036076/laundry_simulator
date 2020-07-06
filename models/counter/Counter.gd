extends LaundryHolder

func _ready() -> void:
	._ready()
	offset = Vector2(-5, -25)
	EventHub.connect("occupy_object", self, "be_occupied")
	EventHub.connect("leave_object", self, "be_free")
	
func disallowed_action() -> void:
	$AnimationPlayer.play("shake")

func get_jump_launch_position() -> Vector2:
	return $JumpLaunch.global_position

func get_sleep_position() -> Vector2:
	return $SleepLocation.global_position
	
func be_occupied(id : int) -> void:
	if id == get_instance_id(): interactable = false

func be_free(id : int) -> void:
	if id == get_instance_id(): interactable = true

