extends BaseCustomer
class_name OldLady

func _ready():
	speed = 50
	score_multiplier = 40
	patience_unit = 0.01
	patience = 1.25
	
func happy_buff() -> void:
	var buff = preload("res://characters/customers/effects/love_aura/love_aura.tscn").instance()
	buff.position = buff_offset
	call_deferred("add_child", buff)

func on_patience_cloud(_area : Area2D, _points : int)-> void:
	return #this customer type is unaffected
