extends Node2D
signal animation_finished

func play():
	$AnimationPlayer.play("show")

func _on_animation_finished(anim_name):
	emit_signal("animation_finished")
