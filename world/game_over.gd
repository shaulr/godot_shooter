extends CanvasLayer
@onready var game = $"/root/Game"
@onready var subtitle = $subtitle

func _ready():
	game.play_random_sad_song()
	subtitle.text = get_random_subtitle()
	
func _on_menu_pressed():
	game.load_level(game.game_menu)

func _on_restart_pressed():
	get_tree().reload_current_scene()
	queue_free()
	
func get_random_subtitle():
	var slogans = [ "Another defeat for proletariat", 
					"I do not ask for mercy, nor do I offer it",
					"O painful daylight, never so hard yet",
					"Go, mother, tell the kin, that I fell for liberty",
					"It is with sadness that we accompany you to the cold grave"]
	return slogans[randi()%slogans.size()]
