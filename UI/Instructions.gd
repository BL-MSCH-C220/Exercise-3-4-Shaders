extends Control

func _ready():
	get_tree().paused = true
	
func set_instructions(n,i):
	$Name.text = n
	$Instructions.text = i

func _on_Timer_timeout():
	Global.starting_in -= 1
	$Starting.text = "Starting in " + str(Global.starting_in)
	if Global.starting_in <= 0:
		var HUD = get_node_or_null("/root/Game/UI/HUD")
		if HUD != null:
			HUD.show()
		get_tree().paused = false
		queue_free()
