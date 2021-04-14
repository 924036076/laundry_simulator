extends Control


func _ready():
	EventHub.connect("interactable_broadcasted", self, "_on_interactable_broadcasted")
	$Description.visible = false
	$NinePatchRect/ScrollContainer/VBoxContainer/StoreItem2.grab_focus()


func _on_interactable_broadcasted(description):
	$Description/Label.text = description
	$Description.visible = true


func _on_ExitButton_pressed():
	queue_free()
