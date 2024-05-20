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
	DEATH
}

const SPEED = 100.0
const JUMP_VELOCITY = -400.0


# The path to the interactibles tilemap
@export var collision_tilemap_path: NodePath

# The layer in the collision tilemap for the interactibles
@export var interactibles_layer: int = 1

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

@export var player_info: PlayerInfo

@export var allow_input = true


# Emitted when the player dies
signal player_died

# Emitted when the player collects money 
signal player_collected_money

# Emitted when the player collects harpoon ammo 
signal player_collected_ammo

# Emitten when a player crosses a checkpoint
signal player_checkpoint


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")	# Get gravity from project settings
var player_state = PlayerState.IDLE
var direction = Vector2(0,0)
var collision_tilemap: TileMap
var jump_timer_start = false
var jump_weight_add = horizontal_jump_weight
var shoot_dir = Vector2(0,0)
var harpoon_projectile
var knockback_dir = Vector2(0,0)


func _ready():
	retrieve_nodes()
	#player_died.connect(Gabagool.reload_scene)
	Gabagool.transition_level_load.connect(_on_transition_level_load)
	print_ammo()


# Reloads any nodes important to the player (like the collision tilemap)
func retrieve_nodes():
	collision_tilemap = get_node(collision_tilemap_path)

func input_just_pressed(input):
	return allow_input and Input.is_action_just_pressed(input)


func input_pressed(input):
	return allow_input and Input.is_action_pressed(input)


# Handles inputs and player state
func _process(_delta):
	if player_state == PlayerState.DEATH:
		return
	
	# Get the input direction and handle the movement/deceleration.
	if allow_input and (!is_jumping() and !is_midair()) or player_state == PlayerState.HARPOON_GLIDE_END:
		direction = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	elif is_shooting():
		direction = Vector2(0,0)
		
	if direction.x < 0.0:
		$AnimatedSprite2D.flip_h = true
	elif direction.x > 0.0:
		$AnimatedSprite2D.flip_h = false
	
	# Check for what interactible tiles the player is on
	#   This part checks for the markers in $TileTest to see if a tile on those 
	#   markers are climbables
	var can_climb = false
	if collision_tilemap and interactibles_layer < collision_tilemap.get_layers_count():
		for child in $TileTest.get_children():
			var tilepos = Gabagool.global_position_to_tile(child.global_position, collision_tilemap)
			var tiledata = collision_tilemap.get_cell_tile_data(1, tilepos)

			# Check the tile data of the cell the player is on
			if tiledata:
				# Check for climbables
				can_climb = can_climb or tiledata.get_custom_data("Climbable")
				if can_climb: 
					if allow_input and input_pressed("player_up"):
						player_state = PlayerState.CLIMB

	# Check if the player is on the harpoon tile
	if player_state == PlayerState.HARPOON_GLIDE and harpoon_projectile:
		for child in $TileTest.get_children():
			var dist = (harpoon_projectile.global_position - child.global_position).length()
			if dist < 40.0 and (is_on_floor() or is_on_wall() or is_on_ceiling()):
				player_state = PlayerState.HARPOON_GLIDE_END
				break
			
	# Player state things
	if player_state == PlayerState.CLIMB:
		$AnimatedSprite2D.play("jump")
		# Player state when climbing
		if is_on_floor() and !can_climb:
			player_state = PlayerState.IDLE
		elif not is_on_floor() and !can_climb:
			player_state = PlayerState.FALL
	elif player_state == PlayerState.HARPOON_GLIDE_END:
		if input_just_pressed("player_jump"):
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
				$AnimatedSprite2D.play("jump")
		else:
			if can_jump():
				# Jumping
				if jump_delay:
					# Delayed jump
					player_state = PlayerState.JUMP_INIT
					$JumpTimer.start(jump_delay)
					jump_timer_start = true
					$AnimatedSprite2D.play("idle")
				else:
					# Instant jump
					jump_impulse()
			elif can_walk() and direction.x:
				# Walking
				$AnimatedSprite2D.play("walk")
				player_state = PlayerState.WALK
			elif player_state != PlayerState.JUMP_INIT and !is_shooting():
				# At leaset idle if not jumping
				if player_state == PlayerState.FALL:
					$LandSFX.play()
				player_state = PlayerState.IDLE
				$AnimatedSprite2D.play("idle")


# Handle shooting things
func _input(event):
	if allow_input and player_info.harpoon_ammo != 0 and !is_dead() and event is InputEventMouseButton and input_just_pressed("player_shoot") and !is_midair():
		if !harpoon_projectile or harpoon_projectile.is_queued_for_deletion():
			# Get the shooting direction
			var event_position = event.position
			shoot_dir = (event_position - get_viewport().get_visible_rect().size / 2).normalized()
			$AnimatedSprite2D.flip_h = true if shoot_dir.x < 0 else false
			
			# Set player state
			player_state = PlayerState.SHOOT
			velocity.x = 0
			$ShootTimer.start()
			$AnimatedSprite2D.play("shoot_init")


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
	elif is_dead():
		velocity = knockback_dir * 10.0

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
		if body is StaticBody2D:
			pass
	move_and_slide()


# Call this when you want to save the player info for a checkpoint
func checkpoint(respawn_point):
	player_info.checkpoint_position = respawn_point
	Gabagool.set_respawn_info(player_info)
	player_checkpoint.emit()
	pass


# Call this to add money to the player
func add_money(worth):
	$CoinSFX.pitch_scale = 1 + randf_range(-0.25, .25)
	$CoinSFX.play()
	player_info.money += worth
	player_collected_money.emit()
	
	
func add_ammo(ammo):
	$CoinSFX.pitch_scale = 1 + randf_range(-0.25, .25)
	$CoinSFX.play()
	player_info.harpoon_ammo += ammo
	player_collected_ammo.emit()
	print_ammo()
	
	
func print_ammo():
	$HarpoonAmo/Label.text = ''
	if player_info.harpoon_ammo > 0:
		for i in range(player_info.harpoon_ammo):
			$HarpoonAmo/Label.text += '|'


# Call this to handle player hurting. This reloads the scene, by the way
func hurt():
	$HurtSFX.play()
	$AnimationPlayer.play("death")
	knockback_dir = -velocity.normalized()
	player_died.emit()
	player_state = PlayerState.DEATH
	velocity = Vector2(0,0)
	$JumpTimer.stop()
	$ShootTimer.stop()
	await get_tree().create_timer(1).timeout
	Gabagool.reload_scene()
		
		
func _on_shoot_timeout():
	# Load the scene and set the stuff
	var harpoon = preload("res://scene/entity/projectile_harpoon.tscn")
	var speed = 400.0
	var instance = harpoon.instantiate()
	var angle = atan2(shoot_dir.y, shoot_dir.x)
	instance.rotation = angle
	instance.velocity = speed * shoot_dir
	instance.global_position = position
	print_ammo()
	
	# Decrease the harpoon ammo
	#  For debugging purposes, negative ammo is means infinite ammo
	if player_info.harpoon_ammo > 0:
		player_info.harpoon_ammo -= 1
	
	# Instantiate
	add_sibling(instance)
	instance.impact.connect(_on_harpoon_impact)
	instance.dead.connect(_on_harpoon_death)
	harpoon_projectile = instance
	
	$AnimatedSprite2D.play("shoot")
	

func _on_harpoon_death():
	player_state = PlayerState.IDLE
	harpoon_projectile = null

	
func _on_harpoon_impact():
	player_state = PlayerState.HARPOON_GLIDE
	harpoon_projectile.get_node("Timer").stop()
	
	
func _on_transition_level_load():
	retrieve_nodes()


func jump_impulse():
	velocity.y = -jump_velocity * jump_velocity_weight
	player_state = PlayerState.JUMP
	jump_timer_start = false
	$AnimatedSprite2D.play("jump")
	$JumpSFX.play()
	move_and_slide()


func _on_jump_timer_timeout():
	jump_impulse()
	
	
func is_shooting(): return player_state == PlayerState.SHOOT or player_state == PlayerState.HARPOON_GLIDE

func is_midair(): return player_state == PlayerState.JUMP or player_state == PlayerState.FALL

func is_jumping(): return player_state == PlayerState.JUMP or player_state == PlayerState.JUMP_INIT

func is_interacting(): return input_just_pressed("player_up")

func is_dead(): return player_state == PlayerState.DEATH

func at_harpoon_end(): return player_state == PlayerState.HARPOON_GLIDE_END

func can_jump(): return not is_jumping() and input_just_pressed("player_jump") and is_on_floor()

func can_walk(): return (player_state == PlayerState.IDLE or player_state == PlayerState.WALK) and not is_jumping() and not is_shooting()
