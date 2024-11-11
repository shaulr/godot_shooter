class_name BaseScene extends Node


@onready var entrance_markers: Node = $entrance_markers
@onready var camera = $followcam
@onready var tilemap = $NavigationRegion2D/TileMap
signal shooting_sound(noise: int, sound_pos: Vector2)
var level_gui: CanvasLayer

func _enter_tree():
	print_debug("_enter_tree")
	#await get_tree().create_timer(1).timeout
	#Game.saver_loader.scene_loaded_callback()
	#Game.current_level = self


func sound(level: int, pos: Vector2):
	shooting_sound.emit(level, pos)

func _ready():
	level_gui = load("res://UI/level_gui.tscn").instantiate()
	add_child(level_gui)
	camera.init(tilemap)
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



func position_player():
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == scene_manager.last_scene:
			Game._player.global_position = entrance.global_position
		elif entrance is Marker2D and entrance.name == "any": 
			Game._player.global_position = entrance.global_position

func _unhandled_input(event):
	if event.is_action("in_game_menu"):
		Game.in_game_menu()
