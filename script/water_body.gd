extends Node2D

# How the gravity much should the gravity be affected
@export var gravity_weight = 0.2

# How much the water should push up on a object
@export var float_force = 100.0

@export var damp = 1.0

@export var player_terminal_velocity = 5.0

@export var player_walking_speed_weight = 1.5


var restore_gravity = 1.0


func _on_area_2d_body_entered(body):
	change_gravity(body, gravity_weight, true)


func _on_area_2d_body_exited(body):
	change_gravity(body, restore_gravity, false)
		
		
func change_gravity(body, gravity, do_bouyancy):
	if body is Player:
		body.gravity_weight = gravity
		if do_bouyancy:
			body.terminal_velocity_weight = player_terminal_velocity / body.terminal_velocity
			body.walking_speed_weight = player_walking_speed_weight
			body.jump_velocity_weight = 0.5
			body.jump_weight_add = -0.3250
		else:
			body.terminal_velocity_weight = 1.0
			body.walking_speed_weight = 1.0
			body.jump_velocity_weight = 1.0
			body.jump_weight_add = body.horizontal_jump_weight
	elif body is RigidBody2D:
		body.gravity_scale = gravity
		if do_bouyancy:
			body.linear_damp = damp
			body.angular_damp = damp
			body.constant_force = Vector2.UP * float_force
		else:
			body.linear_damp = 0.0
			body.angular_damp = 0.0
			body.constant_force = Vector2(0,0)
