extends Control
export var description = "default description for a default item"

var id := ""
var type
const stocked_text := "BUY"
const out_of_stock_text := "OUT OF STOCK"
var price := 200.0
var stocked_items := 0.0
var owned := 0
var shake_prefix := "[shake level=10]"
var is_new := false


func _ready():
  set_button()


func init(key, dictionary):
  id = key

  var sprite_info = dictionary["sprite_info"]
  $Sprite.texture = load(sprite_info["path"])
  $Sprite.hframes = sprite_info["hframes"]
  $Sprite.vframes = sprite_info["vframes"]
  $Sprite.frame = sprite_info["frame"]
  $Sprite.scale = sprite_info["scale"]

  is_new = dictionary["is_new"]
  type = dictionary["type"]
  description = dictionary["display_name"] + ": " + dictionary["description"]
  price = dictionary["price"]
  stocked_items = dictionary["amount"]
  owned = dictionary["owned"]

  if $Owned/Amount.bbcode_text.begins_with(shake_prefix):
    $Owned/Amount.bbcode_text = shake_prefix + str(owned)
  else:
    $Owned/Amount.bbcode_text = str(owned)
  $Price/Amount.text = "$" + str(price)

  set_button()
  $NewItemDot.visible = is_new


func check_can_purchase(funds):
  var out_of_stock = stocked_items <= 0
  var insufficient_funds = funds < price
  $Button.disabled = out_of_stock or insufficient_funds


func buy():
  $Owned/Amount.bbcode_text = shake_prefix + str(owned)
  EventHub.emit_signal("item_purchased", id)
  $Timer.start()


func _on_StoreItem_gui_input(event):
  if event.is_action_pressed("click"):
    EventHub.emit_signal("interactable_broadcasted", description)
  if event.is_action_pressed("ui_accept") and !$Button.disabled: # TODO: add noise/effect when trying to purchase with insufficient funds
    buy()


func set_button():
  if stocked_items <= 0:
    $Button.text = out_of_stock_text
    $Button.disabled = true
  else:
    $Button.text = stocked_text
    $Button.disabled = false


func _on_StoreItem_focus_entered():
  $AnimationPlayer.play("focus")
  EventHub.emit_signal("interactable_broadcasted", description)
  if is_new:
    EventHub.emit_signal("new_item_viewed", id)
    is_new = false
  $NewItemDot.visible = is_new


func _on_StoreItem_focus_exited():
  $AnimationPlayer.play("idle")


func _on_Timer_timeout():
  $Owned/Amount.bbcode_text = str(owned)


func _on_Button_pressed():
  buy()


func _on_StoreItem_mouse_entered():
  grab_focus()
