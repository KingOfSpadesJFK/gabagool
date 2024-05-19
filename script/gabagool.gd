extends Node

# Where to put the level scenes
const main_scene_root = "/root/Control/SubViewportContainer/SubViewport/MainLevel"
const trans_scene_root = "/root/Control/SubViewportContainer/SubViewport/TransitionLevel"
const control_path = "res://scene/game.tscn"

var main_scene = null
var main_scene_path = "res://scene/level/level1.tscn" # Start with this level
var transition_scene = null
var transition_scene_path = ""
var player = null
var camera = null
var checkpoint_player_info: PlayerInfo
var checkpoint_enabled = false
var running_actual_game = false


# Emited upon level load
signal level_load
signal transition_level_load


func _ready():
	if get_node(main_scene_root):
		main_scene = load(main_scene_path).instantiate()
		get_node(main_scene_root).add_child(main_scene)
		running_actual_game = true
	else:
		# If the control node isn't there, then this is running through other means
		main_scene = get_tree().root.get_child(1)
	
	# Get the player and camera
	player = main_scene.get_node("Entities/Player")
	camera = main_scene.get_node("Entities/Camera")

# 
# A function to get the tilemap position Vector2.
func global_position_to_tile(position: Vector2, tilemap: TileMap) -> Vector2i:
	var local_pos = tilemap.to_local(position)
	return tilemap.local_to_map(local_pos)
	
	
func set_respawn_info(player_info: PlayerInfo):
	checkpoint_player_info = player_info
	checkpoint_enabled = true


# Function to load a transition scene
func load_transition_scene(path):
	ResourceLoader.load_threaded_request(path)
	transition_scene_path = path
	print("Loaded transition scene ", path)
	

func instantiate_transition_scene():
	var loaded = ResourceLoader.load_threaded_get_status(transition_scene_path) == ResourceLoader.THREAD_LOAD_LOADED
	if loaded:	
		# Instantiate the transition scene
		transition_scene = ResourceLoader.load_threaded_get(transition_scene_path).instantiate()
		transition_scene.visible = false

		# Get the old player and camera
		var transPlayer = transition_scene.get_node("Entities/Player")
		var transCamera = transition_scene.get_node("Entities/Camera")
		if transPlayer:
			player.collision_tilemap_path = transPlayer.collision_tilemap_path
			player.interactibles_layer = transPlayer.interactibles_layer
			transPlayer.free()
		if transCamera:
			camera.target_node = transCamera.target_node
			camera.follow_weight = transCamera.follow_weight
			camera.background_camera = transCamera.background_camera
			camera.background_scroll_divisor = transCamera.background_scroll_divisor
			transCamera.free()
		
		# Reparent the player and camera
		var new_parent = transition_scene.get_node("Entities")
		player.reparent(new_parent)
		camera.reparent(new_parent)
		if main_scene.get_node("Entities/Harpoon"):
			main_scene.get_node("Entities/Harpoon").reparent(new_parent)
		
		get_node(trans_scene_root).add_child(transition_scene)
		print("Instantiated transition scene ", transition_scene_path)
		transition_level_load.emit()


# Function to move the transition scene to the main root
#  Unloads the previos scene as well
func transition_scene_to_main():
	main_scene.queue_free()
	transition_scene.reparent(get_node(main_scene_root))
	main_scene = transition_scene
	main_scene_path = transition_scene_path
	transition_scene.visible = true
	print("Old main discarded. Transition to ", transition_scene_path, " completed!")


# Reloads the current scene
func reload_scene():
	call_deferred("_deferred_goto_scene", main_scene_path)


# Goes straight to the scene
func goto_scene(path):
	checkpoint_enabled = false
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	main_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	main_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_node(main_scene_root).add_child(main_scene)
	main_scene_path = path

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	#get_tree().main_scene = main_scene
	level_load.emit()
	
	# Get the new player and camera
	player = main_scene.get_node("Entities/Player")
	camera = main_scene.get_node("Entities/Camera")
	
	# Set checkpoint info to the player and camera
	if checkpoint_enabled:
		player.player_info = checkpoint_player_info
