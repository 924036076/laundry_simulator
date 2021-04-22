extends Interactable
export var story_key = "tutorial"


func interact():
  .interact()
  EventHub.emit_signal("laundry_weekly_clicked", story_key)
  
