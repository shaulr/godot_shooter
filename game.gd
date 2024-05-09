extends Node

@onready var current_level = $"."
@onready var player = $player
@onready var camera = $player/followcam

var mapWidth
var mapHeight
const MAX_MOBS = 100
const INITIAL_MOBS = 4
var mobsKilled = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func load_level(level: String):
	get_tree().change_scene_to_file(level)

		
func spawn_mob():
	var mob = preload("res://enemies/hitler.tscn").instantiate()
	mob.global_position.x = mapWidth*randf()
	mob.global_position.y = mapHeight*randf()
	current_level.add_child(mob)

func mob_killed():
	mobsKilled += 1
	if mobsKilled % 5 == 0:
		player.doing_good()
	if mobsKilled < MAX_MOBS:
		spawn_mob()
	else:
		mobsKilled = 0
		get_tree().reload_current_scene()

func get_all_files(path: String, file_ext := "", files := []):
	var dir = DirAccess.open(path)
	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir() +"/"+ file_name, file_ext, files)
				file_name = dir.get_next()
			else:
				var ext = file_name.get_extension()
				if file_ext and ext != file_ext:
					file_name = dir.get_next()
					continue 
				files.append(dir.get_current_dir() +"/"+ file_name)
				file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)
	return files

func level_loaded(level: Node, map_size):
	mapWidth = map_size.x
	mapHeight = map_size.y
	current_level = level

	for i in range(INITIAL_MOBS):
		spawn_mob()
