extends Washer
var durability = 0
var durability_limit = 3
var sprite_sheet_dir = "res://models/lint_machine/machine_sprite_sheets/"


func _ready():
	._ready()
	load_sprite_sheet()


func _change_laundry_state() -> void:
	laundry.dehairify()


func can_run() -> bool:
	return laundry.can_lint_roll() and durability < durability_limit


func _finish_load():
	._finish_load()
	decrement_durability()


func decrement_durability():
	durability = min(durability + 1, durability_limit)
	load_sprite_sheet()


func load_sprite_sheet():
	var path = sprite_sheet_dir + "/" + str(durability) + ".png"
	var file = File.new()
	if file.file_exists(path):
		$Sprite.texture = load(path)
	else:
		print("ERROR: file not found")


func new_lint_roll():
	durability = 0 
	load_sprite_sheet()
