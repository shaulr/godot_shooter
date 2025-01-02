extends Camera2D
@export var tilemap: TileMap
@export var follow_node: Node2D
var inited = false
# Called when the node enters the scene tree for the first time.
func init(tilemap: TileMapLayer):
	tilemap = get_parent().tilemap
	var mapRect = tilemap.get_used_rect()
	var titleSize = tilemap.tile_set.tile_size
	var worldSizeInPixels = mapRect.size * titleSize
	limit_right = worldSizeInPixels.x * tilemap.scale.x
	limit_bottom = worldSizeInPixels.y * tilemap.scale.y
	follow_node = Game.get_player()
	inited = true

func _process(_delta):
	if inited:
		var player = Game.get_player()
		if player: global_position = player.global_position
