extends Area2D

signal get_hairy

func cat_shedding() -> void:
  emit_signal("get_hairy")
