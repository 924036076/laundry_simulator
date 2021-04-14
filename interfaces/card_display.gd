extends Node2D
export (PackedScene) var CustomerButton

enum State {INACTIVE, ACTIVE, DISPLAYED}
var state = State.INACTIVE
var customers_with_buttons = []
var highlight_modulate = Color(.93, .86, .65)
var normal_modulate = Color(1,1,1)


func _ready():
  init()
  set_visibility()
  EventHub.connect("new_customer", self, "_on_new_customer")
  EventHub.connect("day_over", self, "_on_day_over")
  EventHub.connect("new_day", self, "_on_new_day")


func init():
  for customer in Global.Customers:
    if Global.Customers[customer]["visits"] != 0:
      add_button(customer)


func set_visibility():
  print("setting_viz")
  match state:
    State.INACTIVE:
      $ScrollContainer.visible = false
      $Card.visible = false
      $TextureButton.visible = false
      $Background.visible = false
    State.ACTIVE:
      $ScrollContainer.visible = false
      $Card.visible = false
      $TextureButton.visible = true
      $Background.visible = false
    State.DISPLAYED:
      $ScrollContainer.visible = true
      $TextureButton.visible = false
      $Background.visible = true


func add_button(customer : String):
  if customers_with_buttons.has(customer): return
  
  var customer_button = CustomerButton.instance()
  customer_button.init(customer)
  customers_with_buttons.append(customer)
  $ScrollContainer/VBoxContainer.add_child(customer_button)
  customer_button.connect("customer_button_pressed", self, "_on_customer_button_pressed")
  if state == State.INACTIVE:
    state = State.ACTIVE


func _on_customer_button_pressed(customer):
  $Card.init(customer)
  $Card.play_card_display()


func _on_new_customer(customer):
  add_button(customer)
  if state == State.INACTIVE:
    state = State.ACTIVE
  set_visibility()


func _on_ExitButton_pressed():
  state = State.ACTIVE
  $TextureButton.modulate = normal_modulate
  $Background/ButtonBackground/ExitButton.modulate = normal_modulate
  get_tree().paused = false
  $AnimationPlayer.play_backwards("display")
  $Card.play_fade_away()


func _on_ExitButton_mouse_entered():
  $Background/ButtonBackground/ExitButton.modulate = highlight_modulate


func _on_ExitButton_mouse_exited():
  $Background/ButtonBackground/ExitButton.modulate = normal_modulate


func _on_TextureButton_pressed():
  state = State.DISPLAYED
  $AnimationPlayer.play("display")
  print("displaying ui!")
  get_tree().paused = true


func _on_TextureButton_mouse_entered():
  $TextureButton.modulate = highlight_modulate


func _on_TextureButton_mouse_exited():
  $TextureButton.modulate = normal_modulate


func _on_day_over():
  state = State.INACTIVE
  set_visibility()


func _on_new_day():
  if len(customers_with_buttons) > 0:
    state = State.ACTIVE
  set_visibility()


func _on_AnimationPlayer_animation_finished(_anim_name):
  set_visibility()
