extends Node2D


# Gives the spawn point to the singleton. If a scene needs to reload, then spawn here
func _on_area_2d_body_entered(body):
	if body is Player:
		body.checkpoint($SpawnPoint.global_position)
		
