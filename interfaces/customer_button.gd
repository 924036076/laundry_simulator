extends Button
var text_buffer = "      "
var customer_name = ""

signal customer_button_pressed


func init(name_in : String):
	if !Global.Customers.has(name_in):
		return
	customer_name = name_in
	var customer = Global.Customers[customer_name]
	$Sprite.texture = load(customer["sprite_path"])
	text = text_buffer + customer["name"]


func _on_CustomerButton_pressed():
	emit_signal("customer_button_pressed", customer_name)
