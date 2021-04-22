extends CanvasLayer


func _ready():
  EventHub.connect("laundry_times_clicked", self, "_on_laundry_times_clicked")
  EventHub.connect("laundry_times_closed", self, "_on_laundry_times_closed")


func _on_laundry_times_clicked(story_key):
  var laundry_times = preload("res://laundry_times/laundry_times.tscn").instance()
  add_child(laundry_times)
  laundry_times.initialize(story_key)
  get_tree().paused = true


func _on_laundry_times_closed(_story_key):
  get_tree().paused = false
