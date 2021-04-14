extends Node
var customers = ["young_man"]
var weights = [10]
var prob_dist = [1]


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
