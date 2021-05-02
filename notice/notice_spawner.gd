extends CanvasLayer


func _ready():
  EventHub.connect("notice_clicked", self, "_on_notice_clicked")
  EventHub.connect("notice_closed", self, "_on_notice_closed")


func _on_notice_clicked(story_key, story_type):
  var laundry_times = preload("res://notice/notice.tscn").instance()
  add_child(laundry_times)
  laundry_times.initialize(story_key, story_type)
  get_tree().paused = true


func _on_notice_closed(_story_key, _story_type):
  get_tree().paused = false
