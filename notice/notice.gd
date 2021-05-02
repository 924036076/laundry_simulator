extends Control
var story_key
var story_type
var laundry_times_color := Color(0.95, 0.87, 0.76)
var letter_color := Color(0.98, 0.98, 0.98)
export (PackedScene) var Dialog


func _ready():
  _set_buttons()
  $AnimationPlayer.play("appear")


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

const LAWYER_LETTERS = {
  0: {
    "content" : "You are in violation of Laundrocorp’s copyright of the term \"laundry\" \n\n" \
        + "Please cease operations or agree to our payment scheme, unless you " \
        + "have your own highly trained lawyer cat and wish to take this to court, "\
        + "in what could only be a very expensive battle."
   }
 }


func initialize(key, notice_type := "laundry_times"):
  story_type = notice_type

  if notice_type == "letter":
    $ColorRect/ExitButton.visible = false
    $ColorRect/LaundryTimesHeader.visible = false
    $ColorRect/StandardLayout.visible = false
    $ColorRect/LetterLayout.visible = true
    $ColorRect.color = letter_color
    $ColorRect/ExitButton.self_modulate = letter_color
    _set_buttons()
    _set_letter(key)
    return

  # Not a letter, must be Laundry Times
  $ColorRect/LaundryTimesHeader.visible = true
  $ColorRect/StandardLayout.visible = true
  $ColorRect/LetterLayout.visible = false
  $ColorRect.color = laundry_times_color
  $ColorRect/ExitButton.self_modulate = laundry_times_color
  $ColorRect/ExitButton.visible = true
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


func _set_letter(_key):
  # TODO: hook up to letter dictionary and/or array
  $AnimationPlayer.play("appear")


func _set_buttons():
  if GameLogic.get_lawyer_level() <= 0:
    $ColorRect/LetterLayout/Buttons/Challenge.disable_button()
  $ColorRect/LetterLayout/Buttons/Accept.grab_focus()
  

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
  print("exiting")
  EventHub.emit_signal("notice_closed", story_key, story_type)
  queue_free()


func _make_dialog() -> Control:
  var dialog = Dialog.instance()
  $DialogParent.add_child(dialog)
  dialog.connect("dialog_closed", self, "_on_dialog_closed")
  $ColorRect/LetterLayout/Buttons.visible = false
  return dialog


func _on_Quit_pressed():
  var dialog = _make_dialog()
  dialog.init_quit()


func _on_Challenge_pressed():
  pass # TODO: something here when haz lawyer cat


func _on_Accept_pressed():
  var dialog = _make_dialog()
  dialog.init_accept(100) # TODO: logical way of keeping track of new payments
  dialog.connect("payment_accepted", self, "_on_payment_accepted")


func _on_dialog_closed():
  $ColorRect/LetterLayout/Buttons.visible = true


func _on_payment_accepted():
  _exit()


