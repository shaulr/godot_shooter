extends Node

@onready var current_level = $"."

var camera
@onready  var _player: Player 
var mapWidth
var mapHeight
const MAX_MOBS = 100
const INITIAL_MOBS = 4
var mobsKilled = 0
@onready var game_over_node = preload("res://world/game_over.tscn")
@onready var ingame_menu_node = preload("res://UI/in_game_menu.tscn")
@onready var game_menu = "res://UI/main_menu.tscn"
@export var LIVES = 3
var lives = LIVES
var saver_loader:  SaverLoader = SaverLoader.new()
var saved_game: SavedGame
var bosko: Mob
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	
	
func set_saved_data(game_to_save: SavedGame):
	saved_game = game_to_save
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func load_level(level: String):
	#if Game._player:
		#Game._player.get_parent().remove_child(Game._player)
	#get_tree().change_scene_to_file(level)
	scene_manager.change_scene(Game.current_level, level)
func get_random_song() -> String:
	var music_list = []
	get_all_files("res://art/music/songs/", "mp3", music_list)
	var current_song = music_list[randi()%music_list.size()]
	return current_song

func play_random_song():
	if current_level is BaseScene:
		current_level.music_player.set_stream(load(get_random_song()))
		current_level.music_player.play()		

func play_song(song: String):
	if current_level is BaseScene:
		current_level.music_player.set_stream(load(song))
		current_level.music_player.play()

func play_random_sad_song():
	var music_list = []
	get_all_files("res://art/music/death/", "mp3", music_list)
	var current_song = music_list[randi()%music_list.size()]
	#var music_player = AudioStreamPlayer.new()
	if current_level is BaseScene:
		current_level.play_song(current_song)		

func mob_killed():
	mobsKilled += 1
	if mobsKilled % 5 == 0:
		scene_manager.player.doing_good()
	if mobsKilled < MAX_MOBS:
		if current_level.has_method("spawn_mob"):
			current_level.spawn_mob()
	else:
		mobsKilled = 0
		get_tree().reload_current_scene()
		
func game_over():
	var game_over_instance = game_over_node.instantiate()
	current_level.add_child(game_over_instance)
	game_over_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	lives -= 1
	
func in_game_menu():
	var in_game_menu_instance = ingame_menu_node.instantiate()
	current_level.add_child(in_game_menu_instance)
	get_tree().paused = true
	
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
	var music_player = AudioStreamPlayer.new()

	if music_player == null:
		music_player = AudioStreamPlayer.new()
		music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	level.add_child(music_player)
	CampaignManager.level_loaded(level)

func set_player(thePlayer: Player):
	scene_manager.player = thePlayer
	_player = thePlayer
	if !current_level: return 
	#if current_level.has_node("camera"):
		#current_level.camera.follow_node = thePlayer
		
func set_bosko(bosko: Mob):
	self.bosko = bosko

func level_has_camera() -> bool:
	if Game.current_level && Game.current_level.camera: return true
	else: return false

func get_player() -> Player:
	return _player
	
func save():
	#var mobs = get_tree().get_nodes_in_group("mobs")
	#var collectibles = get_tree().get_nodes_in_group("collectibles")
	pass

func start():
	CampaignManager.start("Tutorial")
	
	
func bosko_joins():
	if bosko:
		bosko.follow(_player)
