class_name Fog extends ParallaxBackground
@onready var parallaxLayer = %ParallaxLayer
@onready var colorRect = $ParallaxLayer/ColorRect
var worldSizeInPixels: Vector2
func init(tilemap: TileMapLayer):
	var mapRect = tilemap.get_used_rect()
	var titleSize = tilemap.tile_set.tile_size
	var worldSizeInPixels: Vector2 = mapRect.size * titleSize
	
#func _ready() -> void:
	#parallaxLayer.set_mirroring(worldSizeInPixels)
	#colorRect.set_size(worldSizeInPixels)
	
