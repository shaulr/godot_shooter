extends Area2D
@export var healing: float = 0
@export var drop_chance: float = 0.2
@export var is_consumable: bool = true
@export var item_res: InventoryItem

func collect(inventory: Inventory):
	inventory.insert(item_res)
	queue_free()
	
func get_healing():
	return healing

func get_drop_chance():
	return drop_chance
	
func get_is_consumable():
	return is_consumable
