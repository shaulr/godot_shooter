extends Control
@export var first_level ="res://world/test_level.tscn"

var center : Vector2
@onready var node = $TextureRect
@onready var audio_player = $AudioStreamPlayer

func _on_start_pressed():
	Game.start()

func _ready():
	var visible_rect = get_viewport().get_visible_rect().size
	center = Vector2(visible_rect.x/2, visible_rect.y/2)
	audio_player.play()
	Game.level_loaded(self, get_viewport_rect().size)



func _on_quit_pressed():
	get_tree().quit()
	
func _on_audio_stream_player_finished():
	Game.play_random_song()

		
