extends Interactable
class_name LaundryHolder

var laundry : Node2D = null
var can_give := true
var can_receive := true
var laundry_available := false
onready var laundry_parent : Node2D = $LaundryParent


func load_laundry(laundry_in : Node2D) -> void:
	if !laundry_in: return
	laundry = laundry_in
	laundry_available = true
	laundry_parent.call_deferred("add_child", laundry)


func unload_laundry() -> Node2D:
	if !laundry: return null
	
	var laundry_to_give = laundry
	laundry_parent.remove_child(laundry)
	laundry = null
	laundry_available = false
	return laundry_to_give

		
func reset() -> void:
	if laundry:
		laundry.queue_free()
	laundry = null
	laundry_available = false

