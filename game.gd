extends Node

@onready var current_level = $"."

var camera
@onready  var _player: Player 

const MAX_MOBS = 100
const INITIAL_MOBS = 4
var mobsKilled = 0
@onready var game_over_node = preload("res://world/game_over.tscn")
@onready var ingame_menu_node = preload("res://UI/in_game_menu.tscn")
@onready var game_menu = "res://UI/main_menu.tscn"
@export var LIVES = 3
@export var START_QUEST = "Tutorial"
var current_quest: String
var lives = LIVES
var saver_loader:  SaverLoader = SaverLoader.new()
var saved_game: SavedGame
var bosko: Mob
var is_night = false
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
	#if mobsKilled < MAX_MOBS:
		#if current_level.has_method("spawn_mob"):
			#current_level.spawn_mob()
	else:
		mobsKilled = 0
		get_tree().reload_current_scene()
		
func game_over():
	var game_over_instance = game_over_node.instantiate()
	current_level.add_child(game_over_instance)
	game_over_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	lives -= 1
	var dialog_state: Dictionary = Dialogic.get_full_state()
	if dialog_state && dialog_state.current_timeline:
		Dialogic.end_timeline()
	CampaignManager.player_died(START_QUEST)

	
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

func level_loaded(level: BaseScene):
	current_level = level
	var music_player = AudioStreamPlayer.new()

	if music_player == null:
		music_player = AudioStreamPlayer.new()
		music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	level.add_child(music_player)
	CampaignManager.level_loaded(level)
	create_global_light()
	set_day_night()

func set_player(thePlayer: Player):
	scene_manager.player = thePlayer
	_player = thePlayer
	if !current_level: return 
	#if current_level.has_node("camera"):
		#current_level.camera.follow_node = thePlayer
		
func set_bosko(mybosko: Mob):
	self.bosko = mybosko

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
	var dialog_state = Dialogic.get_full_state()
	CampaignManager.start(START_QUEST)
	
	
func bosko_joins():
	if bosko:
		bosko.follow(_player)
		
func spawn_mobs(mob_path: String, from: Vector2i, to: Vector2i, count: int):
	for i in range(count):
		spawn_mob(mob_path, from, to)
		
func spawn_mob(mob_path: String, from: Vector2i, to: Vector2i):
	var mob = load(mob_path).instantiate()
	mob.global_position = random_position(from, to)
	current_level.add_child(mob)
	while mob.test_move(mob.transform, Vector2(1,1)) == true:
		mob.global_position = random_position(from, to)

func random_position(from: Vector2i, to: Vector2i) -> Vector2:
	var x = randi_range(from.x, to.x)
	var y = randi_range(from.y, to.y)
	return Vector2(x,y)	
	
func create_global_light():
	if "global_light" in current_level && !current_level.global_light:
		var global_light = DirectionalLight2D.new()
		global_light.height = 0
		global_light.color = Color("ff77019b")
		global_light.blend_mode = Light2D.BLEND_MODE_SUB
		if is_night: 
			global_light.energy = 3
		else:
			global_light.energy = 0

		current_level.add_child(global_light)
		current_level.global_light = global_light	
	
func change_to_night():
	create_global_light()
	get_tree().create_tween().tween_property(current_level.global_light, "energy", 3.0, 2)
	play_ambient_sound("res://art/sounds/howlingwolf.ogg")
	await current_level.ambient_sound_player.finished
	play_ambient_sound("res://art/sounds/night_ambient.ogg")
	is_night = true

func set_day_night():
	create_global_light()
	if is_night:
		current_level.global_light.energy = 3.0
		play_ambient_sound("res://art/sounds/night_ambient.ogg")
	else:
		current_level.global_light.energy = 0.0
		play_ambient_sound("res://art/sounds/nature-soundscape.ogg")		

	
func change_to_day():
	is_night = false
	create_global_light()
	get_tree().create_tween().tween_property(current_level.global_light, "energy", 0.0, 2)
	#current_level.remove_child(current_level.global_light)
	#current_level.global_light = null
	play_ambient_sound("res://art/sounds/morningcrow.ogg")
	await current_level.ambient_sound_player.finished
	play_ambient_sound("res://art/sounds/nature-soundscape.ogg")

func play_ambient_sound(sound: String):
	if !current_level.ambient_sound_player:
		current_level.ambient_sound_player = AudioStreamPlayer.new()
		current_level.add_child(current_level.ambient_sound_player)
		current_level.ambient_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
	current_level.ambient_sound_player.set_stream(load(sound)) 
	current_level.ambient_sound_player.play()
	current_level.ambient_sound_player.finished.connect(_on_sound_finished)

func _on_sound_finished():
	current_level.ambient_sound_player.play()
