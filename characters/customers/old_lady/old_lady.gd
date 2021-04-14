extends BaseCustomer
class_name OldLady


func _ready():
	customer_name = "old_lady"
	speed = Global.Customers["old_lady"]["speed"]
	score_multiplier = Global.Customers["old_lady"]["score_multiplier"]
	patience_unit = Global.Customers["old_lady"]["patience_unit"]


func happy_buff() -> void:
	var buff = preload("res://characters/customers/effects/love_aura/love_aura.tscn").instance()
	buff.position = buff_offset
	call_deferred("add_child", buff)
