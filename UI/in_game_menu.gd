extends CanvasLayer

@onready var resume = $HBoxContainer/resume

func _ready():
	resume.grab_focus()

func _unhandled_input(event):
	if event.is_action("in_game_menu"):
		leave_menu()
		
func _on_resume_pressed():
	leave_menu()

func leave_menu():
	get_tree().paused = false
	queue_free()

func _on_main_menu_pressed():
	get_tree().paused = false
	Game.load_level(Game.game_menu)

