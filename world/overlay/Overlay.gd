class_name Overlay
extends TileMap

const TILE_WALL_BLADES := 0


func get_wall_blades() -> Array:
	return self.get_used_cells_by_id(TILE_WALL_BLADES)
