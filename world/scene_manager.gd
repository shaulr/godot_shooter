class_name SceneManager extends Node
var player: Player
var last_scene: String
func change_scene(from, to_scene_name: String):
	last_scene = from.name.get_file().split('.', true, 2)[0]
	player = from.player
	player.get_parent().remove_child(player)
	#Game.player = player
	get_tree().call_deferred("change_scene_to_file", to_scene_name)

