extends RigidBody2D

var min_speed = 100.0
var max_speed = 600.0
var accelerate = false
var time_highlight = 0.4
var time_highlight_size = 0.3

var wobble_period = 0.0
var wobble_amplitude = 0.0
var wobble_max = 5
var wobble_direction = Vector2.ZERO
var decay_wobble = 0.15

var distort_effect = 0.0002

var h_rotate = 0.0

var released = true

var initial_velocity = Vector2.ZERO

var tween = null

func _ready():
	contact_monitor = true
	max_contacts_reported = 8
	if Global.level < 0 or Global.level >= len(Levels.levels):
		Global.end_game(true)
	else:
		var level = Levels.levels[Global.level]
		min_speed *= level["multiplier"]
		max_speed *= level["multiplier"]
	

func _on_Ball_body_entered(body):
	if body.has_method("hit"):
		body.hit(self)
		accelerate = true
		if tween:
			tween.kill()
		tween = create_tween().set_parallel(true)
		$Images/Highlight.modulate.a = 1.0
		tween.tween_property($Images/Highlight, "modulate:a", 0.0, time_highlight)
		$Images/Highlight.scale = Vector2(2.0,2.0)
		tween.tween_property($Images/Highlight, "scale", Vector2(1.0,1.0), time_highlight_size).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
		wobble_direction = linear_velocity.orthogonal().normalized()
		wobble_amplitude = wobble_max
	

func _input(event):
	if not released and event.is_action_pressed("release"):
		apply_central_impulse(initial_velocity)
		released = true

func _integrate_forces(state):
	
	if not released:
		var paddle = get_node_or_null("/root/Game/Paddle_Container/Paddle")
		if paddle != null:
			state.transform.origin = Vector2(paddle.position.x + paddle.width, paddle.position.y - 30)
	else:
		wobble()
		distort()
		comet()
	
	if position.y > Global.VP.y + 100:
		die()
	if accelerate:
		state.linear_velocity = state.linear_velocity * 1.1
		accelerate = false
	if abs(state.linear_velocity.x) < min_speed:
		state.linear_velocity.x = sign(state.linear_velocity.x) * min_speed
	if abs(state.linear_velocity.y) < min_speed:
		state.linear_velocity.y = sign(state.linear_velocity.y) * min_speed
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed


func wobble():
	wobble_period += 1
	if wobble_amplitude > 0:
		var pos = wobble_direction * wobble_amplitude * sin(wobble_period)
		$Images.position = pos
		wobble_amplitude -= decay_wobble

func distort():
	var direction = Vector2(1 + linear_velocity.length() * distort_effect, 1 - linear_velocity.length() * distort_effect)
	$Images.rotation = linear_velocity.angle()
	$Images.scale = direction

func comet():
	h_rotate = wrapf(h_rotate+0.01, 0, 1)
	var comet_container = get_node_or_null("/root/Game/Comet_Container")
	if comet_container != null:
		var sprite = $Images/Sprite2D.duplicate()
		sprite.global_position = global_position
		sprite.modulate.s = 0.6
		sprite.modulate.h = h_rotate
		comet_container.add_child(sprite)

func die():
	queue_free()
