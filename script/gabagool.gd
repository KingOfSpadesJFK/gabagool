extends Node

# Start with this level
const current_scene_path = "res://scene/level/level1.tscn"
const scene_root = "/root/Control/SubViewportContainer/SubViewport"
var current_scene = null
var player = null
var checkpoint_player_info: PlayerInfo
var checkpoint_enabled = false


# Emited upon level load
signal level_load


func _ready():
	if get_node(scene_root):
		current_scene = get_node(scene_root).get_child(0)
	else:
		current_scene = get_tree().root.get_child(1)
	player = current_scene.get_node("Entities/Player")


# A function to get the tilemap position Vector2.
func global_position_to_tile(position: Vector2, tilemap: TileMap) -> Vector2i:
	var local_pos = tilemap.to_local(position)
	return tilemap.local_to_map(local_pos)
	
	
func set_respawn_info(player_info: PlayerInfo):
	checkpoint_player_info = player_info
	checkpoint_enabled = true
	
	
func reload_scene():
	call_deferred("_deferred_goto_scene", current_scene_path)


func goto_scene(path):
	checkpoint_enabled = false
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_node(scene_root).add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	#get_tree().current_scene = current_scene
	level_load.emit()
	
	# Set checkpoint info to the player and camera
	if checkpoint_enabled:
		current_scene.get_node("Entities/Player").position = checkpoint_player_info.checkpoint_position
		current_scene.get_node("Entities/Camera").position = checkpoint_player_info.checkpoint_position
