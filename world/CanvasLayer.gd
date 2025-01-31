class_name LevelGui extends CanvasLayer
@onready var inventory = $inventory
@onready var hearts = $hearts
@onready var hotbar = $hotbar
@onready var info_label = $info_label
@onready var quest_info_label = $quest_info

func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if inventory.is_open:
			inventory.close()
		else:
			inventory.open()
	
func set_label_text(text: String):
	info_label.text = text
	
func set_quest_info(text: String):
	quest_info_label.text = text
