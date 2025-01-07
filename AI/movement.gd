extends Node
class_name Movement

var directions: Array[Vector2]
var raycasts: Array[RayCast2D]
var raycast_length = 30
@onready var parent = get_parent()

func _ready():
	pass
	#directions.append(Vector2.UP.normalized())
	#directions.append((Vector2.UP + Vector2.RIGHT).normalized())
	#directions.append(Vector2.RIGHT.normalized())
	#directions.append((Vector2.DOWN + Vector2.RIGHT).normalized())
	#directions.append(Vector2.DOWN.normalized())
	#directions.append((Vector2.DOWN + Vector2.LEFT).normalized())
	#directions.append(Vector2.LEFT.normalized())
	#directions.append((Vector2.UP + Vector2.LEFT).normalized())
	#for direction in directions:
		#var raycast = RayCast2D.new()
		#raycast.target_position = direction * raycast_length
		#raycast.enabled = true
		#raycast.exclude_parent = true
		#raycast.collide_with_bodies = true
		#raycast.collide_with_areas = false
		#parent.add_child.call_deferred(raycast)
		#raycasts.append(raycast)
	
func pick_direction(desired: Vector2) -> Vector2:
	return Vector2(0,0)
	#var interest_array: Array[float]
	#interest_array.resize(8)
	#interest_array.fill(0.0)
	#var danger_array: Array[float]
	#danger_array.resize(8)
	#danger_array.fill(0.0)
	#var context_map: Array[float]
	#context_map.resize(8)
	#context_map.fill(0.0)
	#for i in range(8):
		#interest_array[i] = directions[i].dot(desired)
		#if raycasts[i].get_collider() != null:
			#danger_array[i] = 5 		
			#if i < 7:
				#if danger_array[i + 1] == 2: 
					#danger_array[i + 1] = 0
				#else:
					#danger_array[i + 1] = 2
			#else:
				#if danger_array[0]  == 2:
					#danger_array[0] = 0
				#else:
					#danger_array[0] = 2
			#
			#if i > 0:
				#if danger_array[i-1] == 2: danger_array[i - 1] = 0 
			#else:
				#if danger_array[7]  == 2: danger_array[i - 1] = 0 				
		#
	#for i in range(8):
		#context_map[i] = interest_array[i] - danger_array[i]
	#
	#var largest: int	
	#var temp: int
	#for i in range(8):
		#if temp < context_map[i]:
			#temp = context_map[i]
			#largest = i
			#
	#return directions[largest]
	

#func _on_timer_timeout():
	#for raycast in raycasts:
		#if raycast.is_colliding():
