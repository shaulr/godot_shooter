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
	#var collision_polygon_points = tile_data.get_collision_polygon_points(0, 0)
	#if collision_polygon_points.size() > 0:
		#print_debug("found collision polygon")
	#var layer_id = tile_set.get_physics_layer_collision_layer(tile_data.terrain)
	#for i in tile_data.get_collision_polygons_count(layer_id):
		#var collision_polygon_points = tile_data.get_collision_polygon_points(layer_id, i)
		#if collision_polygon_points.count > 0:
			#print_debug("found collision polygon")
