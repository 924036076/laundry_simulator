extends Node
var customers = ["young_man"]
var weights = [10]
var prob_dist = [1]
var day := 1
var money := 0 setget set_player_money, get_player_money
var previous_balance

enum ItemType{MACHINE, CONSUMABLE}

#TODO: confirm name for reasonable washer/dryer

const WASHERS = {
  "basic_washer": {
    "time": 5.0,
    "level": 1,
  },
  "reasonable_washer": {
    "time": 2.0,
    "level": 2,
  },
}

const DRYERS = {
  "basic_dryer": {
    "time": 5.0,
    "level": 1,
  },
  "reasonable_dryer": {
    "time": 2.0,
    "level": 2,
  },
}

const LINTERS = {
  "basic_linter": {
    "time": 5.0,
    "level": 1,
  },
}

const COUNTERS = {
  "basic_counter": {
    "level": 1,
  },
  "reasonable_counter": {
    "level": 2,
  },
}

const ITEM_SPRITE_INFO = {
  "basic_toy": {
    "path" : "res://models/toy/mouse-sheet.png",
    "hframes" : 3,
    "vframes" : 1,
    "scale" : Vector2(3,3),
    "frame" : 0,
  },
  "basic_washer": {
    "path" : "res://models/washer/basic_washer.png",
    "hframes" : 2,
    "vframes" : 3,
    "scale" : Vector2(2,2),
    "frame" : 5,
  },
  "reasonable_washer": {
    "path" : "res://models/washer/reasonable_washer.png",
    "hframes" : 2,
    "vframes" : 3,
    "scale" : Vector2(2,2),
    "frame" : 5,
  },
  "basic_dryer": {
    "path" : "res://models/dryer/basic_dryer.png",
    "hframes" : 2,
    "vframes" : 3,
    "scale" : Vector2(2,2),
    "frame" : 5,
  },
  "reasonable_dryer": {
    "path" : "res://models/dryer/reasonable_dryer.png",
    "hframes" : 2,
    "vframes" : 3,
    "scale" : Vector2(2,2),
    "frame" : 5,
  },
  "basic_linter": {
    "path" : "res://models/lint_machine/machine_sprite_sheets/0.png",
    "hframes" : 7,
    "vframes" : 1,
    "scale" : Vector2(2,2),
    "frame" : 5,
  },
  "basic_counter": {
    "path" : "res://models/counter/basic_counter.png",
    "hframes" : 1,
    "vframes" : 1,
    "scale" : Vector2(2,2),
    "frame" : 0,
  },
  "reasonable_counter": {
    "path" : "res://models/counter/reasonable_counter.png",
    "hframes" : 1,
    "vframes" : 1,
    "scale" : Vector2(2,2),
    "frame" : 0,
  },
}

const STORE_ITEMS = {
  "basic_toy" : {
    "display_name" : "Squeakers",
    "description" : "Distracts the cat with its parabolic mouseyness.",
    "price" : 25,
    "type" : ItemType.CONSUMABLE,
  },
  "basic_washer" : {
    "display_name" : "Bessy Washer",
    "description" : "Not much to look at, but she gets the job done.",
    "price" : 5,
    "type" : ItemType.MACHINE,
  },
  "reasonable_washer" : {
    "display_name" : "Maude Washer",
    "description" : "Better than Bessy, and she knows it!",
    "price" : 12,
    "type" : ItemType.MACHINE,
  },
  "basic_dryer": {
    "display_name": "Simon Dryer",
    "description": "Dislikes moisture.",
    "price": 5,
    "type": ItemType.MACHINE,
  },
  "reasonable_dryer" : {
    "display_name" : "Desmond Dryer",
    "description" : "Handsome and reliable.",
    "price" : 16,
    "type" : ItemType.MACHINE,
  },
  "basic_linter" : {
    "display_name" : "Geoffrey Linter",
    "description" : "Meticulous deflufferizer.",
    "price" : 15,
    "type" : ItemType.MACHINE,
  },
  "basic_counter": {
    "display_name" : "Foldmemore Counter",
    "description" : "Folds thrift store finds.",
    "price" : 5,
    "type" : ItemType.MACHINE,
  },
  "reasonable_counter": {
    "display_name" : "Sir Folds A Lot Counter",
    "description" : "Knighted for his folding services.",
    "price" : 25,
    "type" : ItemType.MACHINE,
  },
}

var unlocked_items = [
  "basic_toy",
  "basic_washer",
  "basic_dryer",
  "basic_linter",
  "basic_counter",
]

var newly_unlocked_items = [
  "basic_toy",
  "basic_washer",
  "basic_dryer",
  "basic_linter",
  "basic_counter",
 ]

# TODO: These amounts need to change based on the layout...
#       Consider a mechanism to auto populate the amounts based on the layouts
var store_inventory = {
  "basic_toy" : INF,
  "basic_washer" : 1,
  "reasonable_washer": 2,
  "basic_dryer" : 1,
  "reasonable_dryer": 2,
  "basic_linter" : 1,
  "basic_counter" : 3,
  "reasonable_counter": 4,
 }

var player_inventory = {
  "basic_toy" : 0,
  "basic_washer" : 1,
  "basic_dryer" : 1,
  "basic_linter": 0,
  "basic_counter" : 1,
 }


func get_player_money():
  return money


func set_player_money(new_money):
  money = new_money
  EventHub.emit_signal("money_updated", money)


func reset_player_money(new_money):
  money = new_money
  EventHub.emit_signal("money_reset", money)


func update_unlocked_items() -> void:
  if not "reasonable_washer" in unlocked_items:
    if store_inventory["basic_washer"] == 0:
      unlocked_items.append("reasonable_washer")
      newly_unlocked_items.append("reasonable_washer")
  if not "reasonable_dryer" in unlocked_items:
    if store_inventory["basic_dryer"] == 0:
      unlocked_items.append("reasonable_dryer")
      newly_unlocked_items.append("reasonable_dryer")
  if not "reasonable_counter" in unlocked_items:
    if store_inventory["basic_counter"] == 0:
      unlocked_items.append("reasonable_counter")
      newly_unlocked_items.append("reasonable_counter")


func get_unlocked_store_inventory():
  var unlocked_dic = {}
  for key in unlocked_items:
    if OS.is_debug_build():
      assert(key in store_inventory, key + " should be in store_inventory")
      assert(key in ITEM_SPRITE_INFO, key + " should be in ITEM_SPRITE_INFO")
    unlocked_dic[key] = STORE_ITEMS[key]
    unlocked_dic[key]["owned"] = player_inventory[key] if key in player_inventory else 0
    unlocked_dic[key]["amount"] = store_inventory[key]
    unlocked_dic[key]["sprite_info"] = ITEM_SPRITE_INFO[key]
    unlocked_dic[key]["is_new"] = newly_unlocked_items.has(key)
  return unlocked_dic


func get_player_machines() -> Dictionary:
  var washers := {}
  var dryers := {}
  var linters := {}
  var counters := {}
  for item in player_inventory:
    if item in WASHERS:
      washers[item] = {
        "amount": player_inventory[item],
        "params": WASHERS[item],
        "sprite_info": ITEM_SPRITE_INFO[item],
      }
    elif item in DRYERS:
      dryers[item] = {
        "amount": player_inventory[item],
        "params": DRYERS[item],
        "sprite_info": ITEM_SPRITE_INFO[item],
      }
    elif item in COUNTERS:
      counters[item] = {
        "amount": player_inventory[item],
        "params": COUNTERS[item],
        "sprite_info": ITEM_SPRITE_INFO[item],
      }
    elif item in LINTERS:
      linters[item] = {
        "amount": player_inventory[item],
        "params": LINTERS[item],
        "sprite_info": ITEM_SPRITE_INFO[item],
      }
  var machines := {
    "washers": washers,
    "dryers": dryers,
    "linters": linters,
    "counters": counters,
  }
  return machines


func get_consumable_inventory(key):
  if player_inventory.has(key):
    return player_inventory[key]
  else:
    return 0


func _ready():
  EventHub.connect("day_over", self, "_on_day_over")
  EventHub.connect("item_purchased", self, "_on_item_purchased")
  EventHub.connect("add_money", self, "_on_add_money")
  EventHub.connect("new_game", self, "_on_new_game")
  EventHub.connect("new_day", self, "_on_new_day")
  EventHub.connect("tutorial_started", self, "_on_tutorial_started")
  EventHub.connect("new_item_viewed", self, "_on_new_item_viewed")
  EventHub.connect("consumable_used", self, "_on_consumable_used")


func _on_day_over():
  update_unlocked_items()
  if Global.day == 1:
    add_customer("influencer", 8)
  if Global.day == 2:
    add_customer("old_lady", 5)


func _on_new_day():
  previous_balance = money


func _on_new_game():
  reset_player_money(0)
  previous_balance = 0


func _on_tutorial_started():
  reset_player_money(74998)


func _on_new_item_viewed(key):
  if newly_unlocked_items.has(key):
    newly_unlocked_items.erase(key)
    EventHub.emit_signal("inventory_updated")


func _on_consumable_used(key):
  player_inventory[key] = player_inventory[key] - 1


func get_probability_dist():
  return prob_dist


func get_day_count():
  return day


func get_previous_balance():
  return previous_balance


func get_customer_list():
  return customers


func has_new_unlocked_items() -> bool:
  return newly_unlocked_items.size() > 0


func calculate_probability_dist():
  var total = 0.0

  for i in len(customers):
    total += weights[i]

  prob_dist = []
  var count = 0
  for i in len(customers):
    prob_dist.append((weights[i]+count)/total)
    count += weights[i]
  print("new prob dist: ", prob_dist)


func add_customer(customer_name, weight):
  if customers.has(customer_name):
    var index = customers.find(customer_name)
    if weights[index] != weight:
      weights[index] = weight
    return

  customers.append(customer_name)
  weights.append(weight)
  calculate_probability_dist()


func _on_add_money(amount):
  set_player_money(money + amount)


func _on_item_purchased(item_key, amount = 1):
  EventHub.emit_signal("add_money", -STORE_ITEMS[item_key]["price"] * amount)
  if player_inventory.has(item_key):
    player_inventory[item_key] = player_inventory[item_key] + amount
  else:
    player_inventory[item_key] = amount
  store_inventory[item_key] = store_inventory[item_key] - amount
  EventHub.emit_signal("inventory_updated")
