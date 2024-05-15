extends Node


const scene_root = "/root/Control/SubViewportContainer/SubViewport"
var current_scene = null
var player = null


func _ready():
	if get_node(scene_root):
		current_scene = get_node(scene_root).get_child(0)
		player = current_scene.get_node("Entities/Player")


# A function to get the tilemap position Vector2.
func global_position_to_tile(position: Vector2, tilemap: TileMap) -> Vector2i:
	var local_pos = tilemap.to_local(position)
	return tilemap.local_to_map(local_pos)

func goto_scene(path):
	call_deferred("_deferred_goto_level", path)
	pass
	
func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
