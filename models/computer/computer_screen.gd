extends CanvasLayer
var highlight_modulate = Color(.93, .86, .65)
var normal_modulate = Color(1,1,1)

func _ready():
	$Screen/ExitButton.modulate = normal_modulate
	
	
func _on_ExitButton_pressed():
	pass # Replace with function body.


func _on_ExitButton_mouse_entered():
	$Screen/ExitButton.modulate = highlight_modulate


func _on_ExitButton_mouse_exited():
	$Screen/ExitButton.modulate = normal_modulate


func _on_Button_pressed():
	pass # Replace with function body.
	# TBD: animation for success or failure depending on money -- or just send signal and wait for response on what to do
