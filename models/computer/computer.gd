extends Interactable

export (PackedScene) var Screen
var can_buy := false


func _ready():
	EventHub.connect("add_money", self, "_on_add_money")
	EventHub.connect("new_option", self, "_on_new_option")
	enable_light(false)


func interact():
	.interact()
	show_screen()


func show_screen():
	var screen = Screen.instance()
	add_child(screen)
	if can_buy:
		screen.enable_purchase()


func _on_add_money(_money):
	can_buy = true


func enable_light(boolean = true):
	$Light2D.enabled = boolean
	$Screen.visible = boolean
	
	if boolean:
		$AudioStreamPlayer.play()


func _on_new_option():
	enable_light()
