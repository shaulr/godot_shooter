class_name BaseScene extends Node


@onready var entrance_markers: Node = $entrance_markers
var camera: Camera2D
@onready var tilemap = $NavigationRegion2D/ground
signal shooting_sound(noise: int, sound_pos: Vector2)
var level_gui: LevelGui
var fog: Fog
var music_player: AudioStreamPlayer
var global_light: DirectionalLight2D
var ambient_sound_player: AudioStreamPlayer
@export var inside: bool = false
 
func _enter_tree():
	print_debug("_enter_tree")
	#await get_tree().create_timer(1).timeout
	#Game.saver_loader.scene_loaded_callback()
	Game.current_level = self
	


func sound(level: int, pos: Vector2, friendly: bool):
	shooting_sound.emit(level, pos, friendly)

func _ready():
	level_gui = load("res://UI/level_gui.tscn").instantiate()
	add_child(level_gui)
	camera = load("res://world/followcam.tscn").instantiate()
	add_child(camera)
	
	if !inside:
		fog = load("res://world/fog.tscn").instantiate()
		fog.init(tilemap)
		camera.add_child(fog)
	camera.init(tilemap)
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	Game.current_level = self
	for child in get_children():
		if child is Player: 
			Game._player = child
	if Game.saver_loader.saved_game:
		return		
	
	if is_instance_valid(Game._player):
		if Game._player.get_parent() != self:

			add_child(Game._player)
		position_player()
	Game.level_loaded(self)
		
func play_song(song: String):
	music_player.set_stream(load(song))
	music_player.play()

func position_player():
	if scene_manager.last_scene:
		var door = find_door(self, scene_manager.last_scene)
		if door:
			door.position_player()
			return
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == scene_manager.last_scene:
			Game._player.global_position = entrance.global_position
		elif entrance is Marker2D and entrance.name == "any": 
			Game._player.global_position = entrance.global_position
			
func find_door(node: Node, level: String) -> Door:
	for N in node.get_children():
		if N is Door && N.scene_to_load == level:
			return N
		elif N.get_child_count() > 0:
			find_door(N, level)
	return null
			
func _unhandled_input(event):
	if event.is_action("in_game_menu"):
		Game.in_game_menu()
