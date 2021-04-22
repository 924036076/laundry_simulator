extends Control
var story_key


# TODO: personalize main story in first issue
const STORIES = [
  { #0
    "main": {
      "title": "New Laundromat Makes Waves",
      "content": "Grandchild to the late, great Landon Washerman is the latest to enter" \
          + " the laundry game, albeit with what can only be described as a humble store." \
          + " Will they rise to the occasion or be next in line to sell to Laundrocorp?"
     },
    "fluff": {
      "title": "Laundrocorp valued at Four Trillion Billion",
      "content": "Does it make economic sense? No. Is it true? Yes."
     },
    "info": {
      "title": "Cats + Machines = enemies?",
      "content": "Keep clothes safe from fur! New study finds that some cats refuse to sleep on machines."
     },
    
   }
 ]

const SPECIAL_STORIES = {
  "tutorial": {
    "main": {
      "title": "Laundry Empire Folds ",
      "content": "Landon Washerman created an unforgettable legacy, with stores around " \
          + " the globe and an untarnished reputation for personal service. \n\nToday his" \
          + " children sold that legacy to Laundrocorp."
     },
    "fluff": {
      "title": "Laundrocorp: we care! Come today for buy one, get one. *Lost tickets mean lost laundry - sowwy!*",
      "content": ""
     },
    "info": {
      "title": "New Line of Washers Released",
      "content": "The latest in laundry innovation is the Bessy washer! Shiny and new, plus cleans 2x faster."
     },
   }
 }


func initialize(key):
  match typeof(key):
    TYPE_STRING:
      if SPECIAL_STORIES.has(key):
        _set_stories(key, SPECIAL_STORIES)
      else:
        print("following special story does not exist in dictionary: ", key)
        _exit()
    TYPE_INT:
      if STORIES.size() > key:
        _set_stories(key, STORIES)
      else:
        print("story index out of bounds, exiting")
        _exit()
    _:
      print("unknown key type for Laundry Weekly, exiting")
      _exit()


func _set_stories(key, location):
  # TODO: cache stories already shown? So can look back on them?
  story_key = key 
  $ColorRect/StandardLayout/MainStory/Title.text = location[key]["main"]["title"]
  $ColorRect/StandardLayout/MainStory/Content.text = location[key]["main"]["content"]
  $ColorRect/StandardLayout/FluffStory/Title.text = location[key]["fluff"]["title"]
  $ColorRect/StandardLayout/FluffStory/Content.text = location[key]["fluff"]["content"]
  $ColorRect/StandardLayout/InfoStory/Title.text = location[key]["info"]["title"]
  $ColorRect/StandardLayout/InfoStory/Content.text = location[key]["info"]["content"]
  $AnimationPlayer.play("appear")


func _on_ExitButton_pressed():
  $AnimationPlayer.play("disappear")


func _on_AnimationPlayer_animation_finished(anim_name):
  if anim_name == "disappear":
    _exit()


func _exit():
  EventHub.emit_signal("laundry_times_closed", story_key)
  queue_free()
