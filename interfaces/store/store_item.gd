extends Control
export var description = "default description for a default item"

var out_of_stock := false
var is_machine := false
var is_consumable := false
const stocked_text := "BUY"
const out_of_stock_text := "OUT OF STOCK"
var price := 200
var amount := 0
var owned := 0


func _ready():
  set_button() 


func init(dictionary):
  var sprite_info = dictionary["sprite_info"]
  $Sprite.texture = load(sprite_info["path"])
  $Sprite.hframes = sprite_info["hframes"]
  $Sprite.vframes = sprite_info["vframes"]
  $Sprite.frame = sprite_info["frame"]
  $Sprite.scale = sprite_info["scale"]
  
  is_machine = dictionary["is_machine"]
  is_consumable = dictionary["is_consumable"]
  description = dictionary["description"]
  price = dictionary["price"]
  amount = dictionary["amount"]
  owned = dictionary["owned"]

  $Owned/Amount.bbcode_text = str(owned)
  $Price/Amount.text = "$" + str(price)


func buy():
  owned += 1
  $Owned/Amount.bbcode_text = "[shake level=10]" + str(owned)
  EventHub.emit_signal("add_money", -price)
  $Timer.start()


func _on_StoreItem_mouse_entered():
  pass
  #EventHub.emit_signal("interactable_broadcasted", description)


func _on_StoreItem_gui_input(event):
  if event.is_action_pressed("click"):
    EventHub.emit_signal("interactable_broadcasted", description)
  if event.is_action_pressed("ui_accept"):
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
