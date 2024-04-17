extends Node2D
@onready var game = $"/root/Game"
@onready var pivot_point = $pivot_point

signal is_visible(visible: bool)
var inVision = false;

func _ready():
	add_raycasts(30, -30, 6)
	
func add_raycasts(start_angle: int, end_angle: int, cnt: int):
	var arc = start_angle - end_angle
	var arc_offset = arc/cnt
	for i in cnt:
		var raycast = RayCast2D.new()  
		raycast.target_position = Vector2(0, 100)
		raycast.rotation_degrees = (start_angle - 90) - (i * arc_offset)
		#raycast.collision_mask = 32
		raycast.enabled = true
		raycast.exclude_parent = true
		raycast.collide_with_bodies = true
		raycast.collide_with_areas = false
		pivot_point.add_child(raycast)

		
#func is_colliding_with_player(raycast: RayCast2D) -> bool:
	#var objects_collide = [] 
	#var player = game.player
	#var colliding_with_player = false
	#
	#while raycast.is_colliding():
		#var obj = raycast.get_collider()
		#if !obj.has_method("get_collision_layer_value"): 
			#print_debug("intersected with tilemap")
			#break
		#if obj == game.player: 
			#colliding_with_player = true
			#break
#
		#objects_collide.append( obj )
		#raycast.add_exception( obj ) 
		#raycast.force_raycast_update() 
#
	##after all is done, remove the objects from ray's exception.
	#for obj in objects_collide:
		#raycast.remove_exception( obj )
	#
	#return colliding_with_player
		
func _on_timer_timeout():
	for raycast in $pivot_point.get_children():
		if !raycast.has_method("is_colliding"): continue
		if raycast.is_colliding():
			if raycast.get_collider() == game.player:
				if !inVision: 
					inVision = true
					emit_signal("is_visible", true)
					return

	if inVision:
		inVision = false
		emit_signal("is_visible", false)


	

