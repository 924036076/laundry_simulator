extends Control
export var description = "default description for a default item"

var out_of_stock := false
const stocked_text := "BUY"
const out_of_stock_text := "OUT OF STOCK"
var stocked_items := 10
var cost := 200


func _ready():
	set_button() 
	# TODO: load stock, price info


func buy():
	$HBoxContainer/Label2.bbcode_text = "[shake level=10]" + str(stocked_items)
	EventHub.emit_signal("add_money", -cost)
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
	$HBoxContainer/Label2.bbcode_text = str(stocked_items)
