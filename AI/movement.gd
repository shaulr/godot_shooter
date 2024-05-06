extends Node

var directions: Array[Vector2]
var raycasts: Array[RayCast2D]
var raycast_length = 1000
@onready var parent = get_parent()

func _ready():
	directions.append(Vector2.UP.normalized())
	directions.append((Vector2.UP + Vector2.RIGHT).normalized())
	directions.append(Vector2.RIGHT.normalized())
	directions.append((Vector2.DOWN + Vector2.RIGHT).normalized())
	directions.append(Vector2.DOWN.normalized())
	directions.append((Vector2.DOWN + Vector2.LEFT).normalized())
	directions.append(Vector2.LEFT.normalized())
	directions.append((Vector2.UP + Vector2.LEFT).normalized())
	for direction in directions:
		var raycast = RayCast2D.new()
		raycast.target_position = direction * raycast_length
		raycast.enabled = true
		raycast.exclude_parent = true
		raycast.collide_with_bodies = true
		raycast.collide_with_areas = false
		parent.add_child(raycast)
		raycasts.append(raycast)


func _on_timer_timeout():
	for raycast in raycasts:
		if raycast.is_colliding():
			print_debug("collided at " + raycast.get_collider().global_position)
