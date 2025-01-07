extends Node2D
@onready var pivot_point = $pivot_point
@onready var movement = $movement
var directions: Array[Vector2]
var danger_raycasts: Array[RayCast2D]
var vision_raycasts: Array[RayCast2D]

signal is_visible(visible: bool)
var inVision = false;
var desired_direction = Vector2.ZERO
@onready var light = $pivot_point/PointLight2D
var parent: Mob
func _ready():
	add_raycasts(30, -30, 6, 200, pivot_point, vision_raycasts)
	add_raycasts(90, 360 + 90, 8, 20, movement, danger_raycasts)
	add_directions()
	if get_parent() is Mob:
		parent = get_parent()
	
func add_directions():
	directions.append(Vector2.UP.normalized())
	directions.append((Vector2.UP + Vector2.RIGHT).normalized())
	directions.append(Vector2.RIGHT.normalized())
	directions.append((Vector2.DOWN + Vector2.RIGHT).normalized())
	directions.append(Vector2.DOWN.normalized())
	directions.append((Vector2.DOWN + Vector2.LEFT).normalized())
	directions.append(Vector2.LEFT.normalized())
	directions.append((Vector2.UP + Vector2.LEFT).normalized())
	
func add_raycasts(start_angle: int, end_angle: int, cnt: int, len: int, parent: Node2D, storage: Array[RayCast2D]):
	var arc = start_angle - end_angle
	var arc_offset = arc/cnt
	for i in cnt:
		var raycast = RayCast2D.new()  
		raycast.target_position = Vector2(0, len)
		raycast.rotation_degrees = (start_angle - 90) - (i * arc_offset)
		raycast.enabled = true
		raycast.exclude_parent = true
		raycast.collide_with_bodies = true
		raycast.collide_with_areas = false
		parent.add_child(raycast)
		storage.append(raycast)

func calculate_direction():
	var intrest_vector = [0, 0, 0, 0, 0, 0, 0, 0]
	var danger_vector = [0, 0, 0, 0, 0, 0, 0, 0]
	desired_direction = parent.get_desired_location() 
	for i in directions.size():
		intrest_vector[i] = desired_direction.dot(directions[i])
		if danger_raycasts[i].is_colliding():
			danger_vector[i] = 5
			if i == 0:
				danger_vector[danger_vector.size() - 1] = 2
			else: 
				danger_vector[i - 1] = 2
				
			if i == (danger_vector.size() - 1):
				danger_vector[0] = 2
			else:
				danger_vector[i + 1] = 2
	
	var desired_vector = [0, 0, 0, 0, 0, 0, 0, 0]
	for i in intrest_vector.size():
		desired_vector[i] = intrest_vector[i] - danger_vector[i]
	var candidate = 0
	var temp_max = -100
	var desired_calculated_vector = Vector2.ZERO
	for i in desired_vector.size():
		if temp_max <= desired_vector[i]:
			candidate = i 
			temp_max = desired_vector[i]
			desired_calculated_vector = directions[i]
	
	parent.set_desired_vector(desired_calculated_vector)
	
		
func _on_timer_timeout():
	calculate_direction()
	var objects_collide = []
	for raycast in $pivot_point.get_children():
		if !raycast.has_method("is_colliding"): continue
		if raycast.is_colliding():
			var collider = raycast.get_collider()

			if collider == Game.get_player() || collider.has_method("is_enemy"):
				objects_collide.append(collider)
				if !inVision: 
					inVision = true
					
	if objects_collide.size() > 0:
		emit_signal("is_visible", true, objects_collide)
		return

		
	if inVision:
		inVision = false
		emit_signal("is_visible", false, objects_collide)

func set_desired_location(location: Vector2):
	desired_direction = (global_position - location).normalized()
	
func off():
	light.enabled = false
	queue_free()
