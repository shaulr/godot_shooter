extends TileMapLayer
@onready var objects = %objects

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	#multiply by scale of ground tiles to find correct ones
	var fixed_vector = Vector2i(coords.x*scale.x,  coords.y*scale.y)
	
	if fixed_vector in objects.get_used_cells_by_id():
		return true
		
	return false
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	var fixed_vector = Vector2i(coords.x*scale.x,  coords.y*scale.y)

	if fixed_vector in objects.get_used_cells_by_id():
		tile_data.set_navigation_polygon(0, null)	
