extends Control

export (PackedScene) var StoreItem
onready var item_parent = $NinePatchRect/ScrollContainer/VBoxContainer


func _ready():
  EventHub.connect("interactable_broadcasted", self, "_on_interactable_broadcasted")
  $Description.visible = false
  var item_list = GameLogic.get_unlocked_store_inventory()
  populate_store(item_list)
  if .get_child_count() > 0:
    item_parent.get_child(0).grab_focus()


func populate_store(list):
  for item in list:
    var new_item = StoreItem.instance()
    new_item.init(list[item])
    item_parent.add_child(new_item)


func _on_interactable_broadcasted(description):
  $Description/Label.text = description
  $Description.visible = true


func _on_ExitButton_pressed():
  queue_free()


func _on_ConsumableCheck_pressed():
  for child in item_parent.get_children():
    if child.is_consumable:
      child.visible = true
    else:
      child.visible = false


func _on_MachineCheck_pressed():
  for child in item_parent.get_children():
    if child.is_machine:
      child.visible = true
    else:
      child.visible = false


func _on_All_pressed():
  for child in item_parent.get_children():
    child.visible = true
