extends StaticBody2D

var decay = 0.01

func _ready():
	pass

func _physics_process(_delta):
	if $ColorRect.color.s > 0:
		$ColorRect.color.s -= decay
	if $ColorRect.color.v < 1:
		$ColorRect.color.v += decay

func hit(_ball):
	$ColorRect.color = Color8(201,42,42)
	var wall_audio = get_node_or_null("/root/Game/Wall_Audio")
	if wall_audio != null:
		wall_audio.play()
	
