extends Node2D
class_name Collectible


# Info for the collectable
@export var collectable_info: CollectableInfo

# Emitted when collected
signal collected


# This class just exists to be collected
func _on_area_2d_body_entered(body):
	if body is Player:
		if collectable_info:
			collectable_info.collect(body)
		collected.emit()
		queue_free()
