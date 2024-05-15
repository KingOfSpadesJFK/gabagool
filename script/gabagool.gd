extends Node

# A function to get the tilemap position Vector2.
func global_position_to_tile(position: Vector2, tilemap: TileMap) -> Vector2i:
	var local_pos = tilemap.to_local(position)
	return tilemap.local_to_map(local_pos)
