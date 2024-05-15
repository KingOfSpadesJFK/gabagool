extends CharacterBody2D
class_name Player

enum PlayerState { 
	IDLE, 
	WALK, 
	JUMP, 
	JUMP_INIT, 
	FALL, 
	CLIMB, 
	SHOOT, 
	SHOOT_END, 
	HARPOON_GLIDE, 
	HARPOON_GLIDE_END,
}

const SPEED = 100.0
const JUMP_VELOCITY = -400.0


# The path to the interactibles tilemap
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

# Timer for jump delay. If 0, then player will jump instantly
@export var jump_delay = 0.1

# How much the player weighs
@export var mass = 1.0

@export var terminal_velocity = 10.0

@export var terminal_velocity_weight = 1.0

@export var horizontal_jump_weight = 0.5

@export var money = 0


signal player_died


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")	# Get gravity from project settings
var player_state = PlayerState.IDLE
var direction = Vector2(0,0)
var tilemap: TileMap
var jump_timer_start = false
var jump_weight_add = horizontal_jump_weight
var shoot_dir = Vector2(0,0)
var harpoon_projectile


func _ready():
	tilemap = get_node(tilemap_path)


# Handles inputs and player state
func _process(_delta):
	# Get the input direction and handle the movement/deceleration.
	if (!is_jumping() and !is_midair()) or player_state == PlayerState.HARPOON_GLIDE_END:
		direction = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	elif is_shooting():
		direction = Vector2(0,0)
	
	# Check for what tiles the player is on
	#   This part checks for the markers in $TileTest to see if a tile on those 
	#   markers are climbables
	var can_climb = false
	if tilemap:
		for child in $TileTest.get_children():
			var tilepos = Gabagool.global_position_to_tile(child.global_position, tilemap)
			var tiledata = tilemap.get_cell_tile_data(0, tilepos)

			# Check the tile data of the cell the player is on
			if tiledata:
				# Check for climbables
				can_climb = can_climb or tiledata.get_custom_data("Climbable")
				if can_climb: 
					if Input.is_action_pressed("player_up"):
						player_state = PlayerState.CLIMB

	# Check if the player is on the harpoon tile
	if player_state == PlayerState.HARPOON_GLIDE:
		if get_node("../../Tilemaps"):
			for tm in get_node("../../Tilemaps").get_children():
				for marker in $TileTest.get_children():
					var tilepos = Gabagool.global_position_to_tile(marker.global_position, tm)
					if harpoon_tile_check(tilepos):
						player_state = PlayerState.HARPOON_GLIDE_END
			
	# Player state things
	if player_state == PlayerState.CLIMB:
		# Player state when climbing
		if is_on_floor() and !can_climb:
			player_state = PlayerState.IDLE
		elif not is_on_floor() and !can_climb:
			player_state = PlayerState.FALL
	elif player_state == PlayerState.HARPOON_GLIDE_END:
		if Input.is_action_just_pressed("player_jump"):
			# Instant jump at the end of the hookshot
			jump_impulse()
			harpoon_projectile.queue_free()
			harpoon_projectile = null
		return
	elif player_state != PlayerState.HARPOON_GLIDE:
		if not is_on_floor():
			# Mid-air player state
			if player_state != PlayerState.JUMP or (player_state == PlayerState.JUMP and velocity.y > 0.0):
				player_state = PlayerState.FALL
		else:
			if can_jump():
				# Jumping
				if jump_delay:
					# Delayed jump
					player_state = PlayerState.JUMP_INIT
					$JumpTimer.start(jump_delay)
					jump_timer_start = true
				else:
					# Instant jump
					jump_impulse()
			elif player_state != PlayerState.JUMP_INIT and !is_shooting():
				# At leaset idle if not jumping
				player_state = PlayerState.IDLE
		if  can_walk() and direction:
			# Walking
			player_state = PlayerState.WALK


# Loop through the tiles surrounding tilepos
func harpoon_tile_check(tilepos: Vector2i):
	for harpTilepos in harpoon_projectile.get_tilemap_positions():
		for x in range(-1, 2):
			for y in range(-1, 2):
				if tilepos + Vector2i(x,y) == harpTilepos:
					return true
	return false


# Handle shooting things
func _input(event):
	if event is InputEventMouseButton and Input.is_action_just_pressed("player_shoot") and !is_midair():
		if !harpoon_projectile or harpoon_projectile.is_queued_for_deletion():
			# Get the shooting direction
			var event_position = event.position
			shoot_dir = (event_position - get_viewport().get_visible_rect().size / 2).normalized()
			
			# Set player state
			player_state = PlayerState.SHOOT
			velocity.x = 0
			$ShootTimer.start()


# Handle physics and collision
func _physics_process(delta):
	var _jump_init_divisor = 1.0
	if player_state == PlayerState.JUMP_INIT:
		_jump_init_divisor = 4.0
		
	var speed = walking_speed * walking_speed_weight / _jump_init_divisor
	
	# Add the gravity.
	var grav = gravity * gravity_weight
	if player_state != PlayerState.CLIMB and player_state != PlayerState.HARPOON_GLIDE and not is_on_floor():
		velocity.y += grav * delta
	
	# Movement
	if player_state == PlayerState.CLIMB:
		# Climbing movement
		if direction:
			velocity = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.y = move_toward(velocity.y, 0, speed)
	elif can_walk():
		# Normal walking movement
		if direction.x:
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	elif is_jumping() or is_midair():
		# Midair movement
		velocity.x = direction.x * speed * (walking_speed_weight + jump_weight_add)
	elif player_state == PlayerState.HARPOON_GLIDE:
		var p = lerp(position, harpoon_projectile.position, 200.0 * delta)
		velocity = p - position
	elif player_state == PlayerState.HARPOON_GLIDE_END:
		velocity = Vector2(0,0)

	# Terminal velocity
	var tv = terminal_velocity * terminal_velocity_weight
	if abs(velocity.x) > tv:
		var signn = -1 if velocity.x < 0 else 1
		velocity.x = signn * lerp(abs(velocity.x), tv, 5.0 * delta)
	if abs(velocity.y) > tv:
		var signn = -1 if velocity.y < 0 else 1
		velocity.y = signn * lerp(abs(velocity.y), tv, 5.0 * delta)

	# Push any rigid bodies in the way
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var body = col.get_collider()
		if body is RigidBody2D:
			var force = mass * velocity*velocity / 2.0
			force.y *= -1
			var gravForce = mass * Vector2(0,100)
			body.apply_force(-(force+gravForce)*col.get_normal())
	move_and_slide()
		
		
func _on_shoot_timeout():
	# Load the scene and set the stuff
	var harpoon = preload("res://scene/entity/projectile_harpoon.tscn")
	var speed = 400.0
	var instance = harpoon.instantiate()
	var angle = atan2(shoot_dir.y, shoot_dir.x)
	instance.rotation = angle
	instance.velocity = speed * shoot_dir
	instance.global_position = global_position + 45.0 * shoot_dir
	
	# Instantiate
	add_sibling(instance)
	instance.impact.connect(_on_harpoon_impact)
	instance.dead.connect(_on_harpoon_death)
	harpoon_projectile = instance
	

func _on_harpoon_death():
	player_state = PlayerState.IDLE
	harpoon_projectile = null

	
func _on_harpoon_impact():
	player_state = PlayerState.HARPOON_GLIDE
	harpoon_projectile.get_node("Timer").stop()


func jump_impulse():
	velocity.y = -jump_velocity * jump_velocity_weight
	player_state = PlayerState.JUMP
	jump_timer_start = false
	move_and_slide()


# Call this to add money to the player
func add_money(worth):
	money += worth


func _on_jump_timer_timeout():
	jump_impulse()
	
	
func is_shooting(): return player_state == PlayerState.SHOOT or player_state == PlayerState.HARPOON_GLIDE

func is_midair(): return player_state == PlayerState.JUMP or player_state == PlayerState.FALL

func is_jumping(): return player_state == PlayerState.JUMP or player_state == PlayerState.JUMP_INIT

func at_harpoon_end(): return player_state == PlayerState.HARPOON_GLIDE_END

func can_jump(): return not is_jumping() and Input.is_action_just_pressed("player_jump") and is_on_floor()

func can_walk(): return (player_state == PlayerState.IDLE or player_state == PlayerState.WALK) and not is_jumping() and not is_shooting()
