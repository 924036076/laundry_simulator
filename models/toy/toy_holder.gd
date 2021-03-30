extends Interactable
var nav_node
export (PackedScene) var Toy
var toy


func _ready():
	._ready()
	nav_node = get_node("../ToyNav")
	toy = Toy.instance()
	toy.nav_node = nav_node
	add_child(toy)
	EventHub.connect("new_day", self, "_on_new_day")
	

func new_toy():
	if is_instance_valid(toy):
		toy.queue_free()
		
	toy = Toy.instance()
	toy.nav_node = nav_node
	add_child(toy)
	$Sprite.visible = true
	interactable = true


func interact():
	if !interactable: return
	if !toy: return
	
	toy.release()
	interactable = false
	$Sprite.visible = false


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
	new_toy()
