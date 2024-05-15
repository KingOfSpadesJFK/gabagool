extends RigidBody2D


# Emitted when the player collects the treasure
signal treasure_collected


# How much this treasure is worth
@export var worth = 1000.00

var collected = false
var opened = false


func _on_key_collected():
	$AnimatedSprite2D.play("open")
	opened = true


func _on_area_2d_body_entered(body):
	if opened and not collected:
		if body is Player:
			body.add_money(worth)
			treasure_collected.emit()
			collected = true
			$AnimatedSprite2D.play("collected")
