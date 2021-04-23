extends CanvasLayer

export (PackedScene) var StoreItem
export (PackedScene) var FilterCheckbox
onready var item_parent = $NinePatchRect/ScrollContainer/VBoxContainer
onready var checkbox_parent = $NinePatchRect/Checkboxes
var item_types := []
var highlight_types := []


func _ready():
  EventHub.connect("interactable_broadcasted", self, "_on_interactable_broadcasted")
  EventHub.connect("money_updated", self, "_on_money_updated")
  EventHub.connect("inventory_updated", self, "_on_inventory_updated")
  $Description.visible = false

  var item_list = GameLogic.get_unlocked_store_inventory()
  populate_store(item_list)
  order_children()
  if .get_child_count() > 0:
    item_parent.get_child(0).grab_focus()

  var funds = GameLogic.get_player_money()
  check_funds(funds)


func populate_store(list):
  for item in list:
    var new_item = StoreItem.instance()
    new_item.init(item, list[item])
    item_parent.add_child(new_item)
    if !list[item]["type"] in item_types:
      item_types.append(list[item]["type"])
    if list[item]["is_new"] and !list[item]["type"] in highlight_types:
      highlight_types.append(list[item]["type"])
  
  for type in item_types:
    var new_checkbox = FilterCheckbox.instance()
    checkbox_parent.add_child(new_checkbox)
    new_checkbox.init(type, highlight_types.has(type))
    new_checkbox.connect("filter_activated", self, "_on_filter_activated")
    new_checkbox.group = checkbox_parent.get_node("All").group


func update_inventory(item_list):
  for list_object in item_parent.get_children():
    var key = list_object.id
    list_object.init(key, item_list[key])


func check_funds(funds):
  for child in item_parent.get_children():
    child.check_can_purchase(funds)


func order_children():
  var last_place = item_parent.get_child_count() - 1
  for child in item_parent.get_children():
    if child.is_new:
      item_parent.move_child(child, 0)
    if child.stocked_items <= 0:
      item_parent.move_child(child, last_place)


func _on_money_updated(new_value):
  check_funds(new_value)


func _on_interactable_broadcasted(description):
  $Description/Label.text = description
  $Description.visible = true


func _on_inventory_updated(_groups, _tables):
  var item_list = GameLogic.get_unlocked_store_inventory()
  update_inventory(item_list)
  call_deferred("check_funds", GameLogic.get_player_money())


func _on_ExitButton_pressed():
  queue_free()


func _on_filter_activated(filter):
  var first_item = null
  for child in item_parent.get_children():
    if child.type == filter:
      child.visible = true
      if first_item == null:
        first_item = child
    else:
      child.visible = false
  $Description.visible = false
  first_item.grab_focus()


func _on_All_pressed():
  for child in item_parent.get_children():
    child.visible = true
  $Description.visible = false
