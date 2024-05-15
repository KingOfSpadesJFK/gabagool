extends Node2D


# Whether this area should kill ONLY the player
@export var kill_only_player: bool = false


func _on_area_2d_body_entered(body):
	if body is Player:
		body.hurt()
	elif body is RigidBody2D or\
		body is StaticBody2D or\
		body is CharacterBody2D:
		body.queue_free()
