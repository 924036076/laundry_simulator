extends Node2D

func _ready():
	$AnimationPlayer.play("hide")

func show():
	$AnimationPlayer.play("show")

func hide():
	$AnimationPlayer.play("hide")
