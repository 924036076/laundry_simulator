extends Node

var savegame = File.new()
var save_path = "user://savegame.save"
var save_data = {"highscore": 0}

var max_multiplier = 100
var min_multiplier = 20

var max_patience_unit = 0.03
var min_patience_unit = 0.01


var Customers = {
  "old_lady": {
    "name": "Old Lady",
    "sprite_path": "res://characters/customers/old_lady/sprite.png",
    "ability": "Love Hearts",
    "ability_description": "When very happy, makes surrounding customers happier.",
    "speed": 45,
    "score_multiplier": 20,
    "patience_unit": 0.01,
    "type": "Uncommon",
    "visits": 0
  },
  "young_man": {
    "name": "Young Man",
    "sprite_path": "res://characters/customers/young_man/Male 10-1.png",
    "description": "Utterly unremarkable in every way. Favorite color is cyan.",
    "speed": 55,
    "score_multiplier": 35,
    "patience_unit": 0.018,
    "type": "Common",
    "visits": 0
  },
  "influencer": {
    "name": "Influencer",
    "sprite_path": "res://characters/customers/base_customer/sprite.png",
    "description": "She's late for her goat cafe appointment.",
    "speed": 60,
    "score_multiplier": 30,
    "patience_unit": 0.021,
    "type": "Common",
    "visits": 0
  },
  "lawyer_cat": {
    "name": "Lawyer Cat",
    "sprite_path": "res://characters/customers/lawyer_cat/pipo-nekonin009.png",
    "description": "You do not want to get on their bad side.",
    "speed": 65,
    "score_multiplier": 50,
    "patience_unit": 0.025,
    "type": "Rare",
    "visits": 0
  }

}


func _ready() -> void:
  if not savegame.file_exists(save_path):
    create_save()


func create_save() -> void:
   savegame.open(save_path, File.WRITE)
   savegame.store_var(save_data)
   savegame.close()


func save(high_score : int) -> void:
   save_data["highscore"] = high_score
   savegame.open(save_path, File.WRITE)
   savegame.store_var(save_data)
   savegame.close()


func get_high_score() -> int:
   savegame.open(save_path, File.READ)
   save_data = savegame.get_var()
   savegame.close()
   return save_data["highscore"]
