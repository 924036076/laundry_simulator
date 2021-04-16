extends Interactable
var nav_node
export (PackedScene) var Toy
var toy
var consumable_id = "basic_toy"


func _ready():
  ._ready()
  nav_node = get_node("../ToyNav")
  EventHub.connect("new_day", self, "_on_new_day")
  check_stock()


func new_toy():
  toy = Toy.instance()
  toy.nav_node = nav_node
  add_child(toy)
  $Sprite.visible = true
  interactable = true


func check_stock():
  var stock = GameLogic.get_consumable_inventory(consumable_id)
  if stock > 0 and toy == null:
    new_toy()
  $Label.text = str(stock)
  visible = stock > 0


func interact():
  if !interactable: return
  if !toy: return
  
  toy.release()
  toy = null
  interactable = false
  $Sprite.visible = false
  EventHub.emit_signal("consumable_used", consumable_id)
  call_deferred("check_stock")


func disallowed_action():
  pass


func _calculate_radius():
  radius = get_node("CollisionShape2D").shape.radius


func modulate() -> void:
  if is_target or mouse_over and interactable:
    modulate = selected_modulation
  else:
    modulate = default_modulation


func _on_new_day():
  check_stock()
