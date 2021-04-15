extends Control
export var description = "default description for a default item"

var id := ""
var out_of_stock := false
var type
const stocked_text := "BUY"
const out_of_stock_text := "OUT OF STOCK"
var price := 200
var amount := 0
var owned := 0


func _ready():
  set_button()


func init(key, dictionary):
  id = key
  
  print(dictionary)
  var sprite_info = dictionary["sprite_info"]
  $Sprite.texture = load(sprite_info["path"])
  $Sprite.hframes = sprite_info["hframes"]
  $Sprite.vframes = sprite_info["vframes"]
  $Sprite.frame = sprite_info["frame"]
  $Sprite.scale = sprite_info["scale"]

  type = dictionary["type"]
  description = dictionary["display_name"] + ": " + dictionary["description"]
  price = dictionary["price"]
  amount = dictionary["amount"]
  owned = dictionary["owned"]

  $Owned/Amount.bbcode_text = str(owned)
  $Price/Amount.text = "$" + str(price)
  
  if amount == INF or amount > 0:
    out_of_stock = false
  else:
    out_of_stock = true
    print("out of stock")
  set_button()


func check_can_purchase(funds):
  if funds < price:
    $Button.disabled = true
  else:
    $Button.disabled = false
    

func buy():
  $Owned/Amount.bbcode_text = "[shake level=10]" + str(owned)
  EventHub.emit_signal("item_purchased", id)
  $Timer.start()


func _on_StoreItem_gui_input(event):
  if event.is_action_pressed("click"):
    EventHub.emit_signal("interactable_broadcasted", description)
  if event.is_action_pressed("ui_accept") and !$Button.disabled: # TODO: add noise/effect when trying to purchase with insufficient funds
    buy()


func set_button():
  if out_of_stock:
    $Button.text = out_of_stock_text
    $Button.disabled = true
  else:
    $Button.text = stocked_text
    $Button.disabled = false


func _on_StoreItem_focus_entered():
  $AnimationPlayer.play("focus")
  EventHub.emit_signal("interactable_broadcasted", description)


func _on_StoreItem_focus_exited():
  $AnimationPlayer.play("idle")


func _on_Timer_timeout():
  $Owned/Amount.bbcode_text = str(owned)


func _on_Button_pressed():
  buy()


func _on_StoreItem_mouse_entered():
  EventHub.emit_signal("interactable_broadcasted", description)
