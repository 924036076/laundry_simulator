extends Washer
var durability = 0
var durability_limit = 3
var sprite_sheet_dir = "res://models/lint_machine/machine_sprite_sheets/"
var consumable_id = "basic_lint_roll"


func _ready():
  ._ready()
  load_sprite_sheet()
  EventHub.connect("new_day", self, "_on_new_day")
  EventHub.connect("test_signal", self, "_on_test_signal")


func _on_test_signal():
  decrement_durability()


func check_stock():
  var stock = GameLogic.get_consumable_inventory(consumable_id)
  if stock > 0 and durability >= durability_limit:
    state_machine.call_deferred("travel", "roll_change")    
  $Label.text = str(stock)


func _change_laundry_state() -> void:
  laundry.dehairify()
  EventHub.emit_signal("laundry_delinted")


func can_run() -> bool:
  return laundry.can_lint_roll() and durability < durability_limit


func _finish_load():
  ._finish_load()
  decrement_durability()


func decrement_durability():
  durability = min(durability + 1, durability_limit)
  load_sprite_sheet()
  if durability >= durability_limit:
    call_deferred("check_stock")


func load_sprite_sheet():
  print("load_sprite_sheet")
  var path = sprite_sheet_dir + "state" + str(durability) + ".png"
  $Sprite.texture = load(path)


func load_state(_state:Dictionary) -> void:
  load_sprite_sheet()


func new_lint_roll():
  durability = 0
  load_sprite_sheet()
  EventHub.emit_signal("consumable_used", consumable_id)


func _on_new_day():
  call_deferred("check_stock")


func _on_AnimationPlayer_animation_finished(anim_name):
  print("finished this anim!: ", anim_name)
