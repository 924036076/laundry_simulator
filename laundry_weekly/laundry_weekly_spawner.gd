extends CanvasLayer


func _ready():
  EventHub.connect("laundry_weekly_clicked", self, "_on_laundry_weekly_clicked")


func _on_laundry_weekly_clicked(story_key):
  var laundry_weekly = preload("res://laundry_weekly/laundry_weekly.tscn").instance()
  add_child(laundry_weekly)
  laundry_weekly.initialize(story_key)
