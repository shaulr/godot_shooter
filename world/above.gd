extends TileMapLayer
var ground_layer: int = 1
var above_layer: int = 8

func _check_if_elevated() -> bool:
	var global_pos = Game.get_player().global_position
	var tile_under: Vector2i = local_to_map(global_pos)
	tile_under.x = tile_under.x / scale.x
	tile_under.y = tile_under.y / scale.y

	for tile in get_used_cells_by_id():
		if abs(tile.x - tile_under.x)  <= 1 && abs(tile.y - tile_under.y) <= 1:
			var tile_data = get_cell_tile_data(tile)
			if tile_data && tile_data.get_custom_data("above"):
				return true

	return false

func _set_mask_and_collision(layer: int, value: bool):
	Game.get_player().set_collision_layer_value(layer, value)
	Game.get_player().set_collision_mask_value(layer, value)
	
func _physics_process(delta: float) -> void:
	var make_above_ground: bool = _check_if_elevated()

	_set_mask_and_collision(ground_layer, !make_above_ground)
	_set_mask_and_collision(above_layer, make_above_ground)
