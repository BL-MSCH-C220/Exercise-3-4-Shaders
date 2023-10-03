extends Control

var indicator_margin = Vector2(25, 15)
var indicator_index = 25
var Indicator = load("res://UI/Indicator.tscn")

var fever_h = 0.0
var fever_s = 0.0
var fever_v = 0.0

func _ready():
	update_score()
	update_time()
	update_lives()
	update_fever()
	fever_h = 0.0
	fever_s = 0.78
	fever_v = 0.88

func update_score():
	$Score.text = "Score: " + str(Global.score)

func update_time():
	$Time.text = "Time: " + str(Global.time)

func update_fever():
	$Fever.value = Global.fever

func update_lives():
	var indicator_pos = Vector2(indicator_margin.x, Global.VP.y - indicator_margin.y)
	for i in $Indicator_Container.get_children():
		i.queue_free()
	for i in range(Global.lives):
		var indicator = Indicator.instantiate()
		indicator.position = Vector2(indicator_pos.x + i*indicator_index, indicator_pos.y)
		$Indicator_Container.add_child(indicator)

func _on_Timer_timeout():
	Global.update_time(-1)
