extends TextureButton

export (PackedScene) var Store

var highlight_modulate = Color(.93, .86, .65)
var normal_modulate = Color(1,1,1)

func _ready():
  EventHub.connect("inventory_updated", self, "_on_inventory_updated")
  check_for_new_items()


func check_for_new_items():
  if GameLogic.has_new_unlocked_items():
    $AnimationPlayer.play("new_item")
  else:
    $AnimationPlayer.play("idle")


func _on_inventory_updated(_groups, _tables):
  check_for_new_items()


func _on_TextureButton_mouse_entered():
  modulate = highlight_modulate


func _on_TextureButton_mouse_exited():
  modulate = normal_modulate


func _on_TextureButton_pressed():
  var store = Store.instance()
  get_tree().get_root().add_child(store)
