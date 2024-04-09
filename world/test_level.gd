extends Node2D

@onready var game = $"/root/Game"
@onready var tilemap = $NavigationRegion2D/TileMap

func _ready():
	var mapRect = tilemap.get_used_rect()
	var titleSize = tilemap.cell_quadrant_size
	var worldSizeInPixels = mapRect.size * titleSize
	game.level_loaded(self, worldSizeInPixels)
	
