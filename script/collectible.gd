extends Node2D
class_name Collectible


# Emit
signal collected


# This class just exists to be collected
func _on_area_2d_body_entered(body):
	if body is Player:
		collected.emit()
		queue_free()
