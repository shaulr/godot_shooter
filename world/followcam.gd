extends Camera2D
@export var tilemap: TileMapLayer
@export var follow_node: Node2D
var inited = false
var worldSizeInPixels: Vector2
var inside: bool

var release_falloff = 35
var acceleration = 100
var max_speed = 20
var velocity: Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func init(level_tilemap: TileMapLayer, level_inside: bool):
	inside = level_inside
	tilemap = level_tilemap
	var mapRect = tilemap.get_used_rect()
	var titleSize = tilemap.tile_set.tile_size
	worldSizeInPixels = mapRect.size * titleSize
	limit_right = worldSizeInPixels.x * tilemap.scale.x
	limit_bottom = worldSizeInPixels.y * tilemap.scale.y
	follow_node = Game.get_player()
	inited = true
	zoom = zoom_to_tilemap()
	set_zoom(zoom)
	#apply_camera_limits()
#func _process(_delta):
	#if inited:
		#var player = Game.get_player()
		#if player: global_position = player.global_position


func _process(delta):
	update_global_position()
	pass
	
#func apply_camera_limits():
	#var tilemap_info = get_tilemap_info()
	#var level_size = Vector2i(tilemap_info.tile_size * tilemap_info.size)
#
	#set_limit(SIDE_LEFT, 0)
	#set_limit(SIDE_TOP, 0)
	#set_limit(SIDE_RIGHT, level_size.x)
	#set_limit(SIDE_BOTTOM, level_size.y)
	
func update_global_position():
	global_position = follow_node.global_position 
	#var delta = get_process_delta_time()
	#
	#global_position += lerp(
		#velocity,
		#Vector2.ZERO,
		#pow(2, -32 * delta)
	#)
	#
	#var zoomed_viewport_size = get_viewport_to_zoom_scale()
	#
	#var left_limit = get_limit(SIDE_LEFT)
	#var right_limit = get_limit(SIDE_RIGHT) - zoomed_viewport_size.x
	#var top_limit = get_limit(SIDE_TOP)
	#var bottom_limit = get_limit(SIDE_BOTTOM) - zoomed_viewport_size.y
	#
	#global_position.x = clamp(global_position.x, left_limit, right_limit)
	#global_position.y = clamp(global_position.y, top_limit, bottom_limit)

func get_viewport_to_zoom_scale():
	var zoom_vector = get_zoom()
	var zoomed_viewport_size = Vector2i(
		get_viewport().size[0] / zoom_vector.x,
		get_viewport().size[1] / zoom_vector.y,
	)
	
	return zoomed_viewport_size
func calculate_velocity(direction):
	var delta = get_process_delta_time()
	
	velocity += direction * acceleration * delta
	
	if direction.x == 0:
		velocity.x = lerp(0.0, velocity.x, pow(2, -release_falloff * delta))
	if direction.y == 0:
		velocity.y = lerp(0.0, velocity.y, pow(2, -release_falloff * delta))
		
	velocity.x = clamp(
		velocity.x,
		-max_speed,
		max_speed
	)
	
	velocity.y = clamp(
		velocity.y,
		-max_speed,
		max_speed
	)

func zoom_to_tilemap() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	
	var tilemap_info = get_tilemap_info()
	var level_size = Vector2i(tilemap_info.tile_size * tilemap_info.size)
	level_size.x = level_size.x * tilemap.scale.x
	level_size.y = level_size.y * tilemap.scale.y

	var viewport_aspect = float(viewport_size[0]) / viewport_size[1]
	var level_aspect = float(level_size.x) / level_size.y
	
	var new_zoom = 1.0
	
	if level_aspect > viewport_aspect:
		new_zoom = float(viewport_size[1]) / level_size.y
	else:
		new_zoom = float(viewport_size[0]) / level_size.x
		
	#new_zoom = clamp(new_zoom, 0.0, 1.5)
		
	return Vector2(new_zoom, new_zoom)

func get_tilemap_info():
	var tile_size = tilemap.tile_set.tile_size
	
	var tilemap_rect = tilemap.get_used_rect()
	var tilemap_size = Vector2i(
		tilemap_rect.end.x - tilemap_rect.position.x,
		tilemap_rect.end.y - tilemap_rect.position.y
	)
	
	return {"size": tilemap_size, "tile_size": tile_size}
