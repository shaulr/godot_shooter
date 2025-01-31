class_name Door extends Area2D
@onready var game = $"/root/Game"
@export_file("*.tscn") var scene_to_load: String = "res://world/"
var rect_size = Vector2(32, 32) # example size.
var collider: CollisionShape2D

func _ready():
	collider = $CollisionShape2D	
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body is Player:
		var player_pos = Game.get_player().global_position
		var door_pos = global_position
		print_debug(Game.get_player().global_position)

		scene_manager.change_scene(Game.current_level, scene_to_load)

func position_player():
	var door_position = global_position
	Game.get_player().global_position = door_position
	var bodies_in_area = get_overlapping_bodies()
	if (bodies_in_area.size() > 0):
		move_out_of_range(bodies_in_area)
		return
	elif on_bottom_edge_of_the_map():
		Game.get_player().global_position.y = door_position.y - (Game.get_player().get_size().y * 2 + 20)
		Game.get_player().global_position.x = door_position.x
	elif on_right_edge_of_the_map():
		Game.get_player().global_position.x = door_position.x - (Game.get_player().get_size().x * 2 + 20)
		Game.get_player().global_position.y = door_position.y		
	elif on_left_edge_of_the_map():
		Game.get_player().global_position.x = door_position.x + (Game.get_player().get_size().x * 2)
		Game.get_player().global_position.y = door_position.y		
		print_debug(Game.get_player().global_position)
		#var x = Game.get_player().global_position.x
		#var collider_width = get_rect_of_collider().x
		#var player_width = Game.get_player().get_size().x
		#
		#Game.get_player().global_position.x +=  (collider_width + player_width) * 2	
		#var bodies_in_area_of_door = get_overlapping_areas()
		#if (bodies_in_area_of_door.size() > 0):
			#move_out_of_range(bodies_in_area_of_door)	
	else: 
		Game.get_player().global_position.y += Game.get_player().get_size().y * 2
		
func on_bottom_edge_of_the_map() -> bool:
	var world_size = get_rect_of_level()
	var door_y = global_position.y
	return world_size.y - door_y <= 20
	#var player_below_pos = Game.get_player().global_position.y + Game.get_player().get_size().y * 2
	#return player_below_pos <= world_size.y	+ 20 + Game.get_player().get_size().y	
	#
func on_right_edge_of_the_map() -> bool:
	var world_size = get_rect_of_level()
	var door_x = global_position.x
	return world_size.x - door_x <= 20

	#var player_right_pos = Game.get_player().global_position.x + Game.get_player().get_size().x * 2
	#return player_right_pos >= world_size.x	+ 20	
		
func on_left_edge_of_the_map() -> bool:
	var world_size = get_rect_of_level()
	return global_position.x < 20
	#var player_right_pos = Game.get_player().global_position.x + Game.get_player().get_size().x * 2
	#return player_right_pos <= 20
		
func get_rect_of_collider() -> Vector2:
	if collider.shape is RectangleShape2D:
		return collider.shape.size
	elif collider.shape is CapsuleShape2D:
		return Vector2(collider.shape.height, collider.shape.radius)
	elif collider.shape is CircleShape2D:
		return Vector2(collider.shape.radius, collider.shape.radius)
	else:
		return rect_size

func get_rect_of_level() -> Vector2:
	var mapRect = Game.current_level.tilemap.get_used_rect()
	var titleSize = Game.current_level.tilemap.tile_set.tile_size
	titleSize.x *= Game.current_level.tilemap.scale.x
	titleSize.y *= Game.current_level.tilemap.scale.y
	var worldSizeInPixels = mapRect.size * titleSize
	return worldSizeInPixels
	
func move_out_of_range(bodies):
	var current_position = global_position
	var distance_to_add: float = 0.0
	for body in bodies:
		var direction_from_body_to_self = (current_position- body.global_position)
		# check distance on the X
		if (abs(direction_from_body_to_self.x) < rect_size.x):
			distance_to_add += (get_rect_of_collider().x - abs(direction_from_body_to_self.x))
			distance_to_add = distance_to_add * sign(direction_from_body_to_self.x)
			current_position.x += distance_to_add
		# check distance on the Y
		if (abs(direction_from_body_to_self.y) < rect_size.y):
			distance_to_add += (get_rect_of_collider().y - abs(direction_from_body_to_self.y))
			distance_to_add = distance_to_add * sign(direction_from_body_to_self.y)
			current_position.y += distance_to_add
	Game.get_player().global_position = current_position
