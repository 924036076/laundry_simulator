extends Node

var savegame = File.new() 
var save_path = "user://savegame.save" 
var save_data = {"highscore": 0} 

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
