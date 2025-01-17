class_name SceneManager extends Node
@export var player: Player
@export var last_scene: String
var scene_storage: Dictionary = {}

func change_scene(from, to_scene_name: String, is_door = false):
	if Game._player && Game._player.get_parent():
		player = Game._player
		Game._player.get_parent().remove_child(player)
	if Game.current_level != null && Game.current_level is BaseScene && from != null:
		var serialized_scene = serialize_scene()
		scene_storage[from.scene_file_path] = serialized_scene
		last_scene = from.scene_file_path


	get_tree().call_deferred("change_scene_to_file", to_scene_name)

func exit_scene():
	change_scene(Game.current_level, last_scene)

func serialize_scene() -> Array[SavedData]:
	var saved_data:Array[SavedData] = []
	get_tree().call_group("game_events", "on_save_data", saved_data)
	return saved_data
	
func on_level_loaded(level: String):
	if scene_storage.has(level):
		var stored_scene = scene_storage[level]
		deserialize_scene(stored_scene)
	
func deserialize_scene(savedDataArray: Array[SavedData]):
	#var game_event_nodes = get_tree().get_nodes_in_group("game_events")
	
	#Game.current_level.get_tree().call_group("game_events", "on_pre_load")
	for item in savedDataArray:
		var scene = load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		if restored_node.has_method("on_load"):
			restored_node.on_load(item)
		Game.current_level.add_child(restored_node)

	
