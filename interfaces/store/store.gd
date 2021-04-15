extends CanvasLayer

export (PackedScene) var StoreItem
onready var item_parent = $NinePatchRect/ScrollContainer/VBoxContainer


func _ready():
  EventHub.connect("interactable_broadcasted", self, "_on_interactable_broadcasted")
  EventHub.connect("money_updated", self, "_on_money_updated")
  EventHub.connect("inventory_updated", self, "_on_inventory_updated")
  $Description.visible = false

  var item_list = GameLogic.get_unlocked_store_inventory()
  populate_store(item_list)
  if .get_child_count() > 0:
    item_parent.get_child(0).grab_focus()

  var funds = GameLogic.get_player_money()
  check_funds(funds)


func populate_store(list):
  for item in list:
    var new_item = StoreItem.instance()
    new_item.init(item, list[item])
    item_parent.add_child(new_item)


func update_inventory(item_list):
  for list_object in item_parent.get_children():
    var key = list_object.id
    list_object.init(key, item_list[key])


func check_funds(funds):
  for child in item_parent.get_children():
    child.check_can_purchase(funds)


func _on_money_updated(new_value):
  check_funds(new_value)


func _on_interactable_broadcasted(description):
  $Description/Label.text = description
  $Description.visible = true


func _on_inventory_updated():
  var item_list = GameLogic.get_unlocked_store_inventory()
  update_inventory(item_list)
  call_deferred("check_funds", GameLogic.get_player_money())


func _on_ExitButton_pressed():
  queue_free()


func _on_ConsumableCheck_pressed():
  for child in item_parent.get_children():
    if child.type == GameLogic.ItemType.CONSUMABLE:
      child.visible = true
    else:
      child.visible = false
  $Description.visible = false


func _on_MachineCheck_pressed():
  for child in item_parent.get_children():
    if child.type == GameLogic.ItemType.MACHINE:
      child.visible = true
    else:
      child.visible = false
  $Description.visible = false


func _on_All_pressed():
  for child in item_parent.get_children():
    child.visible = true
  $Description.visible = false
