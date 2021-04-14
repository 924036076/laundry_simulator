extends BaseCustomer


func _ready():
	customer_name = "young_man"
	speed = Global.Customers[customer_name]["speed"]
	score_multiplier = Global.Customers[customer_name]["score_multiplier"]
	patience_unit = Global.Customers[customer_name]["patience_unit"]

