extends Interactable
export var story_key = "tutorial"
export var story_type = "laundry_weekly"


func interact():
  .interact()
  EventHub.emit_signal("notice_clicked", story_key, story_type)
  
