extends Node2D


var time = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Sprite2D.position.y = sin(time*1.0) * 8.0
	$Sprite2D.position.x = cos(time*8.0)
	$Sprite2D.rotation = cos(time/2.30) / (10 * PI)
	time += delta
