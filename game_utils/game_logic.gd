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
    "level": 1
  },
}

const DRYERS = {
  "basic_dryer": {
    "time": 5.0,
    "level": 1
  },
  "reasonable_dryer": {
    "time": 5.0,
    "level": 2
  }
}

const LINTERS = {
  "basic_linter": {
    "time": 5.0,
    "level": 1
  }
}

const COUNTERS = {
  "basic_counter": {
    "level": 1
  }
}

const STORE_ITEMS = {
  "basic_toy" :
    {
    "sprite_info" : {
      "path" : "res://models/toy/mouse-sheet.png",
      "hframes" : 3,
      "vframes" : 1,
      "scale" : Vector2(3,3),
      "frame" : 0
      },
    "display_name" : "Squeakers",
    "description" : "Distract the cat with the good stuff",
    "price" : 25,
    "type" : ItemType.CONSUMABLE
   },
  "basic_washer" :
    {
    "sprite_info" : {
      "path" : "res://models/washer/sprite.png",
      "hframes" : 2,
      "vframes" : 3,
      "scale" : Vector2(2,2),
      "frame" : 5
      },
    "display_name" : "Maude",
    "description" : "Not much to look at, but she gets the job done.",
    "price" : 500,
    "type" : ItemType.MACHINE
   },
  "reasonable_washer" :
    {
    "sprite_info" : {
      "path" : "res://models/washer/sprite.png",
      "h_frames" : 2,
      "v_frames" : 3,
      "scale" : Vector2(2,2),
      "frame" : 5
      },
    "display_name" : "Maude 2",
    "description" : "Not much to look at, but she gets the job done.",
    "price" : 1200,
    "type" : ItemType.MACHINE
   },
  "basic_dryer" :
    {
    "sprite_info" : {
      "path" : "res://models/dryer/sprite.png",
      "hframes" : 2,
      "vframes" : 3,
      "scale" : Vector2(2,2),
      "frame" : 5
      },
    "display_name" : "Alvin",
    "description" : "Painfully unhip, but reliable and cuddly.",
    "price" : 650,
    "type" : ItemType.MACHINE
   },
  "basic_linter" :
    {
    "sprite_info" : {
      "path" : "res://models/lint_machine/machine_sprite_sheets/0.png",
      "hframes" : 7,
      "vframes" : 1,
      "scale" : Vector2(2,2),
      "frame" : 5
      },
    "display_name" : "Geoffrey",
    "description" : "Meticulous deflufferizer",
    "price" : 1500,
    "type" : ItemType.MACHINE
   },
  "basic_counter":
    {
    "sprite_info" : {
      "path" : "res://models/counter/sprite.png",
      "hframes" : 2,
      "vframes" : 2,
      "scale" : Vector2(2,2),
      "frame" : 3
      },
    "display_name" : "shoyo hinata",
    "description" : "super eager fast moving short puppeh",
    "price" : 500,
    "type" : ItemType.MACHINE
  }
 }

var unlocked_items = [
  "basic_toy",
]

var store_inventory = {
  "basic_toy" : INF,
  "basic_washer" : 1,
  "basic_dryer" : 1,
  "basic_linter" : 1,
  "basic_counter" : 3,
 }

var player_inventory = {
  "basic_toy" : 1,
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


func get_unlocked_store_inventory():
  var unlocked_dic = {}
  for key in unlocked_items:
    unlocked_dic[key] = STORE_ITEMS[key]
    unlocked_dic[key]["amount"] = store_inventory[key]
    unlocked_dic[key]["owned"] = player_inventory[key]
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
        "params": WASHERS[item]
      }
    elif item in DRYERS:
      dryers[item] = {
        "amount": player_inventory[item],
        "params": DRYERS[item]
      }
    elif item in COUNTERS:
      counters[item] = {
        "amount": player_inventory[item],
        "params": COUNTERS[item]
      }
    elif item in LINTERS:
      linters[item] = {
        "amount": player_inventory[item],
        "params": LINTERS[item]
      }
  var machines := {
    "washers": washers,
    "dryers": dryers,
    "linters": linters,
    "counters": counters,
  }
  return machines


func _ready():
  EventHub.connect("day_over", self, "_on_day_over")
  EventHub.connect("item_purchased", self, "_on_item_purchased")
  EventHub.connect("add_money", self, "_on_add_money")
  EventHub.connect("new_game", self, "_on_new_game")
  EventHub.connect("new_day", self, "_on_new_day")


func _on_day_over():
  if Global.day == 1:
    add_customer("influencer", 8)
  if Global.day == 2:
    add_customer("old_lady", 5)


func _on_new_day():
  previous_balance = money


func _on_new_game():
  set_player_money(0)
  previous_balance = 0


func get_probability_dist():
  return prob_dist


func get_day_count():
  return day


func get_previous_balance():
  return previous_balance


func get_customer_list():
  return customers


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
    store_inventory[item_key] = store_inventory[item_key] - amount
  # TODO: send signal to update store values
