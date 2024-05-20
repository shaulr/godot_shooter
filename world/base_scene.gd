class_name BaseScene extends Node
@onready var game = $"/root/Game"
@onready var player: Player = $player
@onready var entrance_markers: Node2D = $entrance_markers
func _ready():
	game.current_level = self
	if scene_manager.player:
		if scene_manager.player.get_parent():
			scene_manager.player.get_parent().remove_child(player)
		player = scene_manager.player
		add_child(player)
	position_player()

func position_player():
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == scene_manager.last_scene:
			player.global_position = entrance.global_position
		elif entrance is Marker2D and entrance.name == "any": 
			player.global_position = entrance.global_position
