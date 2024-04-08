extends Node

@onready var current_level = $"."
@onready var player = $player
var mapWidth
var mapHeight
const MAX_MOBS = 100
const INITIAL_MOBS = 10
var mobsKilled = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	init()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func init():
	for i in range(INITIAL_MOBS):
		spawn_mob()
		
func spawn_mob():
	print_debug("spawn mob")
	print_debug(mobsKilled)
	var mob = preload("res://enemies/hitler.tscn").instantiate()
	mob.global_position.x = mapWidth*randf()
	mob.global_position.y = mapHeight*randf()
	current_level.add_child(mob)

func mob_killed():
	mobsKilled += 1
	if mobsKilled < MAX_MOBS:
		spawn_mob()

func level_loaded(level: Node, map_size):
	mapWidth = map_size.x
	mapHeight = map_size.y
	current_level = level
	init()
