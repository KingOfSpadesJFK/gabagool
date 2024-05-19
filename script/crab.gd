extends CharacterBody2D
class_name Crab


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var facing_left = false
@export var speed = 25.0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_wall():
		facing_left = not facing_left
		
	if facing_left:
		velocity.x = -speed
	else:
		velocity.x = speed

	move_and_slide()
