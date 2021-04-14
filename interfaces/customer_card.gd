extends Node2D
var highlight_modulate = Color(.93, .86, .65)
var normal_modulate = Color(1,1,1)
var max_dollars = 10


func _ready():
  pass
#	init("old_lady")
#	play_new_card()


func play_new_card():
  $AnimationPlayer.play("new_anim")


func play_card_display():
  $AnimationPlayer.play("simple_show")


func play_fade_away():
  $AnimationPlayer.play("fade_away")


func init(customer_string):
  print("initializing ", customer_string)
  if !Global.Customers.has(customer_string):
    print("error: customer type not found")
    return
  
  var customer = Global.Customers[customer_string]
  $Card/Label.text = customer["name"]
  $Card/Type.text = customer["type"]
  $Card/Portrait.texture = load(customer["sprite_path"])
  $Card/Portrait/LoveAura.visible = false
  if customer.has("ability"):
    $Card/Details/GenericDescription.visible = false
    $Card/Details/SpecialAbility.visible = true
    $Card/Details/SpecialAbility.text = customer["ability"]
    add_special_ability_visual(customer["ability"])
    $Card/Details/SpecialAbility/Description.text = customer["ability_description"]
  else:
    $Card/Details/SpecialAbility.visible = false
    $Card/Details/GenericDescription.visible = true
    $Card/Details/GenericDescription.text = customer["description"]
  
  calculate_patience_stars(customer["patience_unit"])
  calculate_dollar_signs(customer["score_multiplier"])


func calculate_patience_stars(customer_patience_unit):
  for node in $Card/PatienceLabel.get_children():
    node.visible = false
  
  var patience_stars = $Card/PatienceLabel.get_child_count() - 1
  var star_step = (Global.max_patience_unit - Global.min_patience_unit)/patience_stars
  var counter = 0
  var patience_comp = Global.max_patience_unit
  
  while patience_comp > customer_patience_unit and counter <= patience_stars:
    $Card/PatienceLabel.get_child(counter).visible = true
    counter += 1
    patience_comp -= star_step


func calculate_dollar_signs(customer_multiplier):
  var dollar_text = ""
  var dollar_step = (Global.max_multiplier - Global.min_multiplier)/(max_dollars - 1)
  var dollar_comp = Global.min_multiplier
  var counter = 0
  
  while dollar_comp <= customer_multiplier and counter <= max_dollars - 1:
    dollar_text = dollar_text + "$"
    counter += 1
    dollar_comp += dollar_step

  $Card/TipLabel/TipDescription.text = dollar_text


func add_special_ability_visual(ability):
  match ability:
    "Love Hearts":
      $Card/Portrait/LoveAura.visible = true
      print("love aura visible now")


func _on_TextureButton_pressed():
  $AnimationPlayer.play("delete_away")


func _on_TextureButton_mouse_entered():
  $TextureButton.modulate = highlight_modulate


func _on_TextureButton_mouse_exited():
  $TextureButton.modulate = normal_modulate


func _on_AnimationPlayer_animation_finished(anim_name):
  match anim_name:
    "delete_away":
      EventHub.emit_signal("customer_card_removed")
      queue_free()
    "fade_away":
      $AnimationPlayer.play("idle")
