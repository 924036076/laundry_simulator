extends "res://characters/customers/base_customer/customer.gd"

func _ready():
	speed = 50
	score_multiplier = 40
	patience_unit = 0.01
	patience = 1.25
	
func happy_buff() -> void:
	var buff = preload("res://characters/customers/effects/love_aura/LoveAura.tscn").instance()
	buff.position = Vector2(0, 15)
	call_deferred("add_child", buff)

func on_patience_cloud(_area : Area2D, _points : int)-> void:
	pass
