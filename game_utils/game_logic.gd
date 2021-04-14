extends Node
var customers = ["young_man"]
var weights = [10]
var prob_dist = [1]


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
    "is_consumable" : true,
    "is_machine" : false
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
    "is_consumable" : false,
    "is_machine" : true
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
    "is_consumable" : false,
    "is_machine" : true
   }
 }

var unlocked_items = [
  "basic_toy" 
]

var store_inventory = {
  "basic_toy" : INF,
  "basic_washer" : 1,
  "basic_dryer" : 1
 }

var player_inventory = {
  "basic_toy" : 1,
  "basic_washer" : 1,
  "basic_dryer" : 1
 }


func get_unlocked_store_inventory():
  var unlocked_dic = {}
  for key in unlocked_items:
    unlocked_dic[key] = STORE_ITEMS[key]
    unlocked_dic[key]["amount"] = store_inventory[key]
    unlocked_dic[key]["owned"] = player_inventory[key]
  return unlocked_dic


func _ready():
  EventHub.connect("day_over", self, "_on_day_over")


func _on_day_over():
  if Global.day == 1:
    add_customer("influencer", 8)
  if Global.day == 2:
    add_customer("old_lady", 5)


func get_probability_dist():
  return prob_dist


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
