extends Node2D

func check_level():
	var count = 0
	for c in get_children():
		if not c.dying:
			count += 1
	if count == 0:
		Global.next_level()
