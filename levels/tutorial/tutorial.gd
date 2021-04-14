extends Node2D

var state = State.BEGINNING
enum State {BEGINNING, MOM_ENTRY_1, WASH, WASH_PICKUP, DRY, DRY_PICKUP, FOLD, FOLD_PICKUP, MOM_ENTRY_2, ENDING}

var mom_buffer := 2
var normal_buffer := 1.5
var ending_buffer := 10.0
var computer_bool = false


func _ready():
	EventHub.connect("laundry_washed", self, "_on_laundry_washed")
	EventHub.connect("laundry_dried", self, "_on_laundry_dried")
	EventHub.connect("laundry_folded", self, "_on_laundry_folded")
	EventHub.connect("player_picked_up_laundry", self, "_on_player_picked_up_laundry")
	EventHub.connect("add_money", self, "_on_money_added")
	$Timer.start(mom_buffer)
	$Cat.stop()


func _on_laundry_washed():
	state = State.WASH_PICKUP
	$Timer.start(normal_buffer)


func _on_laundry_dried():
	state = State.DRY_PICKUP
	$Timer.start(normal_buffer)


func _on_laundry_folded():
	state = State.FOLD_PICKUP
	$Timer.start(normal_buffer)


func _on_player_picked_up_laundry():
	increment_state()
	$Timer.start(normal_buffer)


func increment_state():
	match state:
		State.WASH_PICKUP:
			state = State.DRY
		State.DRY_PICKUP:
			state = State.FOLD
		State.FOLD_PICKUP:
			state = State.MOM_ENTRY_2
		


func _on_Timer_timeout():
	print("timer time out in base tutorial script!")
	print("current state is: ", state)
	match state:
		State.BEGINNING:
			$Mom.go_downstairs()
			state = State.MOM_ENTRY_1
		State.MOM_ENTRY_1:
			state = State.WASH
			get_tree().call_group("interactables", "selective_click_me", "washer")
		State.WASH_PICKUP:
			get_tree().call_group("interactables", "selective_click_me", "washer")
		State.DRY:
			get_tree().call_group("interactables", "selective_click_me", "dryer")
		State.DRY_PICKUP:
			get_tree().call_group("interactables", "selective_click_me", "dryer")
		State.FOLD:
			get_tree().call_group("interactables", "selective_click_me", "counter")
		State.FOLD_PICKUP:
			get_tree().call_group("interactables", "selective_click_me", "counter")
			state = State.MOM_ENTRY_2
		State.MOM_ENTRY_2:
			$Mom.retrieve_laundry()
		State.ENDING:
			get_tree().call_group("interactables", "selective_click_me", "computer")


func _on_money_added(_money):
	if computer_bool: return
	
	computer_bool = true
	yield(get_tree().create_timer(normal_buffer), "timeout")
	state = State.ENDING
	EventHub.emit_signal("new_option")
	$Timer.start(ending_buffer)

