extends TextureButton

export (PackedScene) var Store

var highlight_modulate = Color(.93, .86, .65)
var normal_modulate = Color(1,1,1)


func _on_TextureButton_mouse_entered():
  modulate = highlight_modulate


func _on_TextureButton_mouse_exited():
  modulate = normal_modulate


func _on_TextureButton_pressed():
  var store = Store.instance()
  get_tree().get_root().add_child(store)
