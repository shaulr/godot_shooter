extends Control
@onready var game = $"/root/Game"
@export var first_level ="res://world/test_level.tscn"

var center : Vector2
@onready var node = $TextureRect
@onready var audio_player = $AudioStreamPlayer
func _on_start_pressed():
	game.load_level(first_level)

func _ready():
	var visible_rect = get_viewport().get_visible_rect().size
	center = Vector2(visible_rect.x/2, visible_rect.y/2)
	audio_player.play()
#
#func _process(delta):
	#var tween = node.create_tween()
	#var offset = (center - get_global_mouse_position())* 0.1
	#tween.tween_property(node, "position", offset, 1.0)
	


func _on_quit_pressed():
	get_tree().quit()
