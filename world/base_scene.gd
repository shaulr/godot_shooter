class_name BaseScene extends Node

var player: Player
@onready var entrance_markers: Node2D = $entrance_markers
@onready var camera = $followcam

func _enter_tree():
	print_debug("_enter_tree")
	#await get_tree().create_timer(1).timeout
	#Game.saver_loader.scene_loaded_callback()
	Game.current_level = self

func _ready():
	Game.current_level = self

	
	for child in get_children():
		if child is Player: player = child
	if Game.saver_loader.saved_game:
		return		
	if is_instance_valid(player):
		if player.get_parent() != self:
			player.get_parent().remove_child(player)
			add_child(player)
		position_player()



func position_player():
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == scene_manager.last_scene:
			player.global_position = entrance.global_position
		elif entrance is Marker2D and entrance.name == "any": 
			player.global_position = entrance.global_position

func _unhandled_input(event):
	if event.is_action("in_game_menu"):
		Game.in_game_menu()
