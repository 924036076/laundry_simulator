extends Node2D
class_name PatiencePoint

func _ready():
	$AnimationPlayer.play("show")

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
