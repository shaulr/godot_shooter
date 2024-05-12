extends Node

@onready var current_level = $"."
@onready var player = $player
@onready var camera = $player/followcam

var mapWidth
var mapHeight
const MAX_MOBS = 100
const INITIAL_MOBS = 4
var mobsKilled = 0
@onready var game_over_node = preload("res://world/game_over.tscn")
@onready var game_menu = "res://UI/main_menu.tscn"
@export var LIVES = 3
var lives = LIVES
var music_player = AudioStreamPlayer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func load_level(level: String):
	get_tree().change_scene_to_file(level)


func play_random_song():
	var music_list = []
	get_all_files("res://art/music/songs/", "mp3", music_list)
	var current_song = music_list[randi()%music_list.size()]
	music_player.set_stream(load(current_song))
	music_player.play()		

func play_random_sad_song():
	var music_list = []
	get_all_files("res://art/music/death/", "mp3", music_list)
	var current_song = music_list[randi()%music_list.size()]
	music_player.set_stream(load(current_song))
	music_player.play()		

func mob_killed():
	mobsKilled += 1
	if mobsKilled % 5 == 0:
		player.doing_good()
	if mobsKilled < MAX_MOBS:
		if current_level.has_method("spawn_mob"):
			current_level.spawn_mob()
	else:
		mobsKilled = 0
		get_tree().reload_current_scene()
		
func game_over():
	var game_over = game_over_node.instantiate()
	current_level.add_child(game_over)
	get_tree().paused = true
	lives -= 1
	
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
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	level.add_child(music_player)

