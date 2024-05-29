class_name SaverLoader
extends Node
var saved_game: SavedGame = null
var scene_nodes: Dictionary = {}

func save_game():
	var saved_game:SavedGame = SavedGame.new()
	saved_game.level_path = Game.current_level.scene_file_path
	saved_game.player_data = Game.get_player().serialize_player()
	saved_game.saved_data_array = scene_manager.serialize_scene()
	ResourceSaver.save(saved_game, "user://savegame.tres")
	
func load_game():
	saved_game = load("user://savegame.tres") as SavedGame
	if !saved_game: return
	Game.set_saved_data(saved_game)
	var scene = load(saved_game.level_path).instantiate()
	_get_all_descendants(scene)
	Game.current_level.get_tree().call_deferred("change_scene_to_file", saved_game.level_path)
	#Game.current_level.get_tree().change_scene_to_packed(scene)
	Game.current_level.get_tree().node_added.connect(on_node_added)
	
func on_node_added(node:Node) -> void:
	if scene_nodes.has(node.name):
		scene_nodes.erase(node.name)
	if scene_nodes.is_empty(): scene_loaded_callback()


func scene_loaded_callback():
	if saved_game:
		var player = preload("res://player/player.tscn").instantiate()
		Game.current_level.add_child(player)
		scene_manager.deserialize_scene(saved_game.saved_data_array)

		
func player_loaded_callback(player: Player):
	if saved_game: 
		player.deserialize_player(saved_game.player_data, player)
		saved_game = null
		
func _get_all_descendants(node:Node) -> Dictionary:

	scene_nodes[node.name] = node
	
	var children = node.get_children()
	for child in children:
		scene_nodes.merge(_get_all_descendants(child))
	return scene_nodes

