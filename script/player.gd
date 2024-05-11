extends CharacterBody2D
class_name Player

enum PlayerState { IDLE, WALK, JUMP, FALL }

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

# The walking speed of the player
@export var walking_speed = 100.0

# The jump veloctiy of the player
@export var jump_velocity = 400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_state = PlayerState.IDLE
var direction = Vector2(0,0)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if player_state != PlayerState.JUMP:
			player_state = PlayerState.FALL
	else:
		player_state = PlayerState.IDLE

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		player_state = PlayerState.JUMP
		velocity.y = -jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("player_left", "player_right")
	
	if player_can_walk():
		if direction:
			velocity.x = direction * walking_speed
		else:
			velocity.x = move_toward(velocity.x, 0, walking_speed)

	move_and_slide()


func player_can_walk():
	return player_state == PlayerState.IDLE or player_state == PlayerState.WALK
