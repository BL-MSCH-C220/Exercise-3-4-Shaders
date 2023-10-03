extends StaticBody2D

var Sound_Ball = null

func _ready():
	Sound_Ball = get_node_or_null("/root/Main_Menu/Sound_Ball")

func hit(ball):
	ball.max_speed *= 1.05
	ball.min_speed *= 1.05
	ball.max_speed = clamp(ball.max_speed, ball.max_speed, 1500)
	ball.min_speed = clamp(ball.min_speed, ball.min_speed, ball.max_speed)
	if Sound_Ball != null:
		Sound_Ball.play()
