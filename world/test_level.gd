extends Node2D

@onready var game = $"/root/Game"
@onready var tilemap = $NavigationRegion2D/TileMap
@onready var hearts_container = $CanvasLayer/hearts
const INITIAL_MOBS = 1

func _ready():
	var mapRect = tilemap.get_used_rect()
	var titleSize = tilemap.cell_quadrant_size
	var worldSizeInPixels = mapRect.size * titleSize
	game.level_loaded(self, worldSizeInPixels)
	for i in range(INITIAL_MOBS):
		spawn_mob()
	hearts_container.set_max_hearts(game.LIVES)
	hearts_container.set_current_lives(game.lives)

func spawn_mob():
	var mob = preload("res://enemies/hitler.tscn").instantiate()
	mob.global_position.x = game.mapWidth*randf()
	mob.global_position.y = game.mapHeight*randf()
	add_child(mob)


func _on_inventory_inventory_opened():
	get_tree().paused = true


func _on_inventory_inventory_closed():
	get_tree().paused = false
