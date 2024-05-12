extends CharacterBody2D
class_name Player

enum PlayerState { IDLE, WALK, JUMP, JUMP_INIT, FALL, CLIMB }

const SPEED = 100.0
const JUMP_VELOCITY = -400.0


# The path to the foreground tilemap
@export var tilemap_path: NodePath

# The walking speed of the player
@export var walking_speed = 50.0

# Multiplier for the walking speed
@export var walking_speed_weight = 1.0

# The jump veloctiy of the player
@export var jump_velocity = 100.0

# Multiplier for the jump velocity
@export var jump_velocity_weight = 1.0

# Multiplier for the gravity
@export var gravity_weight = 1.0

# Timer for jump delay
@export var jump_delay = 0.1


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")	# Get gravity from project settings
var player_state = PlayerState.IDLE
var direction = Vector2(0,0)
var tilemap: TileMap
var jump_timer_start = false
var jump_direction = Vector2(0,0)

func _ready():
	tilemap = get_node(tilemap_path)


# Handles inputs and player state
func _process(_delta):
	# Get the input direction and handle the movement/deceleration.
	if player_state != PlayerState.JUMP_INIT:
		direction = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	
	# Check for what tiles the player is on
	#   This part checks for the markers in $TileTest to see if a tile on those 
	#   markers are climbables
	var can_climb = false
	for child in $TileTest.get_children():
		# Get the tile data of the cell the player is on
		var pos = tilemap.to_local(child.global_position)
		var posTile = tilemap.local_to_map(pos)
		var tiledata = tilemap.get_cell_tile_data(0, posTile)
		if tiledata:
			# Check for climbables
			can_climb = can_climb or tiledata.get_custom_data("Climbable")
			if can_climb: 
				if Input.is_action_pressed("player_up"):
					player_state = PlayerState.CLIMB
		
	# Player state things
	if player_state == PlayerState.CLIMB:
		if is_on_floor() and !can_climb:
			player_state = PlayerState.IDLE
		elif not is_on_floor() and !can_climb:
			player_state = PlayerState.FALL
	else:
		if not is_on_floor():
			if player_state != PlayerState.JUMP:
				player_state = PlayerState.FALL
		else:
			# Handle jump.
			if player_can_jump():
				player_state = PlayerState.JUMP_INIT
				$JumpTimer.start(jump_delay)
				jump_timer_start = true
				jump_direction = direction
			elif player_state != PlayerState.JUMP_INIT:
				player_state = PlayerState.IDLE
		if  player_can_walk() and direction and player_state != PlayerState.JUMP_INIT:
			player_state = PlayerState.WALK


# Handle physics and collision
func _physics_process(delta):
	var _jump_init_divisor = 1.0
	if player_state == PlayerState.JUMP_INIT:
		_jump_init_divisor = 4.0
		
	var speed = walking_speed * walking_speed_weight / _jump_init_divisor
	
	# Add the gravity.
	if player_state != PlayerState.CLIMB and not is_on_floor():
		velocity.y += gravity * gravity_weight * delta
	
	if player_state == PlayerState.CLIMB:
		if direction:
			velocity = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.y = move_toward(velocity.y, 0, speed)
	elif player_can_walk():
		if direction.x:
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func player_can_jump():
	return player_state != PlayerState.JUMP and Input.is_action_just_pressed("player_jump") and is_on_floor() and player_state != PlayerState.JUMP_INIT


func player_can_walk():
	return player_state == PlayerState.IDLE or player_state == PlayerState.WALK or player_state == PlayerState.JUMP_INIT


func _on_jump_timer_timeout():
	velocity.x = jump_direction.x * walking_speed * walking_speed_weight
	velocity.y = -jump_velocity * jump_velocity_weight
	player_state = PlayerState.JUMP
	jump_timer_start = false
