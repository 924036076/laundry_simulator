extends Node2D

signal new_destination

var nav_node : Navigation2D
var rng : RandomNumberGenerator

var height_offset = 15
var angle_offset = 30
var initial_position 
var destination
var initial_velocity : Vector2
var bounce_time := 1.0
var gravity := -1000
var max_frame
var kick_strength := 150

var count := 0.0
var bounces := 0
var max_bounces := 5

enum State{CAGED, IDLE, TORTURE, KICK, BOUNCE, DEATH}
var state = State.CAGED


func release():
  bounce()



func _ready():
  max_frame = $Sprite.vframes * $Sprite.hframes - 1
  EventHub.connect("play_started", self, "_on_cat_play_started")
  EventHub.connect("play_ended", self, "_on_cat_play_ended")
  rng = RandomNumberGenerator.new()
  set_process(false)
  $Squeak.pitch_scale = 1


func _on_cat_play_started():
  state = State.TORTURE
  $AnimationPlayer.play("torture")


func _on_cat_play_ended():
  decrement_durability()
  bounce()


func _on_Toy_body_entered(body):
  match state:
    State.CAGED:
      return
    State.BOUNCE:
      bounce()
    State.KICK:
      if body.is_in_group("player"):
        return
      else:
        bounce()
    State.IDLE:
      if body.is_in_group("cat"):
        return
      else:
        kick(body.global_position)
        return

  EventHub.emit_signal("toy_bounced_on_body", body)


func decrement_durability():
  if $Sprite.frame == max_frame:
    die()
  else:
    $Sprite.frame += 1
    

func die():
  state = State.DEATH
  $AnimationPlayer.play("death")
  $Squeak.pitch_scale = 0.4
  $Squeak.play()
  


func calculate_random_dest():
  rotation_degrees = rng.randf_range(0, 360)
  # Not allowing bounces that are mostly up or down
  if rotation_degrees > 90 - angle_offset and rotation_degrees < 90 + angle_offset:
    calculate_random_dest()
    return
  if rotation_degrees > 270 - angle_offset and rotation_degrees < 270 + angle_offset:
    calculate_random_dest()
    return


  destination = nav_node.get_closest_point($Position2D.global_position)
  initial_position = global_position
  emit_signal("new_destination", destination)
  rotation_degrees = 0


func calculate_kicked_dest(kicker_pos : Vector2):
  var direction = (global_position - kicker_pos).normalized()
  var kicked_loc = kick_strength * direction + global_position
  
  destination = nav_node.get_closest_point(kicked_loc)
  initial_position = global_position
  emit_signal("new_destination", destination)
  rotation_degrees = 0


func calculate_initial_velocity():
  var x_vel = (destination.x - initial_position.x)/bounce_time
  var y_vel = (destination.y - initial_position.y + 0.5 * gravity * pow(bounce_time, 2)) \
        / bounce_time
  initial_velocity = Vector2(x_vel, y_vel)


func kick(kick_loc : Vector2) -> void:
  state = State.KICK
  $AnimationPlayer.play("takeoff")
  $Squeak.play()
  count = 0.0
  calculate_kicked_dest(kick_loc)
  calculate_initial_velocity()
  EventHub.emit_signal("toy_released", destination + Vector2(0, height_offset))
  #EventHub.emit_signal("toy_released", destination + Vector2(0, height_offset))
  set_process(true)


func bounce() -> void:
  match state:
    State.DEATH:
      return
    State.BOUNCE:
      bounces += 1
    _:
      bounces = 0
      state = State.BOUNCE

  if bounces >= max_bounces:
    return
  
  $Squeak.play()
  $AnimationPlayer.play("takeoff")
  count = 0.0
  calculate_random_dest()
  calculate_initial_velocity()
  EventHub.emit_signal("toy_released", destination + Vector2(0, height_offset))
  set_process(true)


func _process(delta):
  count += delta
  #var new_x = initial_velocity.x * delta + global_position.x
  #var new_y = -0.5 * gravity * (2 * delta + delta*delta) \
#				+ initial_velocity.y * delta  + global_position.y

  var new_x = initial_velocity.x*count + initial_position.x
  var new_y = -0.5*gravity*count*count + initial_velocity.y*count + initial_position.y
        
  global_position = Vector2(new_x, new_y)
  if count >= bounce_time:
    _on_landing()


func _on_landing():
  set_process(false)
  #$CPUParticles2D.emitting = true
  state = State.IDLE
  $AnimationPlayer.play("landing")
  $Landing.play()


func _on_AnimationPlayer_animation_finished(anim_name):
  if anim_name == "death":
    EventHub.emit_signal("toy_destroyed")
    queue_free()
