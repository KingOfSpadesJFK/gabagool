extends Area2D

@export var strength = 10.0

@export var angle = 90.0

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		var rad = -deg_to_rad(angle) + rotation
		var direction = Vector2(cos(rad), sin(rad))
		if body is RigidBody2D:
			body.apply_central_force(direction * strength)
		elif body is CharacterBody2D:
			body.velocity += direction * strength
