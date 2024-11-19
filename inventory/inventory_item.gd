extends Resource

class_name InventoryItem
@export var max_amount_per_stack: int = 10
@export var name: String = ""
@export var texture: Texture2D

func use(player: Player):
	pass
	
