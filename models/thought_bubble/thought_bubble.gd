extends Node2D

func _ready():
	$AnimationPlayer.play("hide")

func show():
	$AnimationPlayer.play("show")

func hide():
	$AnimationPlayer.play("hide")


func _on_Cat_mischief_started():
	$AnimationPlayer.play("hide")
