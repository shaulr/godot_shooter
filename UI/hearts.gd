extends HBoxContainer
@onready var heart_gui_class = preload("res://UI/heart.tscn")

func set_max_hearts(max_hearts: int):
	for i in range(max_hearts):
		var heart = heart_gui_class.instantiate()
		add_child(heart)

func set_current_lives(current: int):
	var hearts = get_children()
	
	for i in range(current):
		hearts[i].update(true)
	for i in range(current, hearts.size()):
		hearts[i].update(false)
