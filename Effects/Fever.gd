extends Node2D

func start_fever():
	fever()
	$Timer.start()

func _on_Timer_timeout():
	if Global.feverish:
		fever()
		$Timer.start()

func fever():
	var ball_container = get_node_or_null("/root/Game/Ball_Container")
	if ball_container != null:
		ball_container.make_ball_fever()
	var camera = get_node_or_null("/root/Game/Camera3D")
	if camera != null:
		camera.add_trauma(3.0)
