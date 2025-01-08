extends Control

var center : Vector2
@onready var node = $TextureRect
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer

func _on_start_pressed():
	Game.start()

func _ready():
	var visible_rect = get_viewport().get_visible_rect().size
	center = Vector2(visible_rect.x/2, visible_rect.y/2)
	audio_player.play()
	#Game.play_random_song()



func _on_quit_pressed():
	get_tree().quit()
	
func _on_audio_stream_player_finished():
	#Game.play_random_song()
	audio_player.set_stream(load(Game.get_random_song()))
	audio_player.play()	
		
