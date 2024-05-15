extends Button

@onready var background: Sprite2D = $background
@onready var center_container: CenterContainer = $CenterContainer

@onready var inventory = preload("res://inventory/inventory.tres")

var item_stack: ItemStack
var index: int

func insert(isg: ItemStack):
	item_stack = isg
	background.frame = 1
	center_container.add_child(item_stack)
	
	if !item_stack.inventory_slot || inventory.slots[index] == item_stack.inventory_slot:
		return
	inventory.insert_slot(index, item_stack.inventory_slot)
	
func take_item():
	var item = item_stack
	background.frame = 0
	inventory.remove_slot(item_stack.inventory_slot)
	center_container.remove_child(item)
	item_stack = null
	return item

func is_empty() -> bool:
	return !item_stack || !item_stack.item

func clear():
	if item_stack:
		center_container.remove_child(item_stack)
		item_stack = null
	background.frame = 0
	
func scale():
	var area_size = background.texture.get_size() * 3/4
	var texture_size = item_stack.item.texture.get_size()
	var sx = area_size.x / texture_size.x
	var sy = area_size.y / texture_size.y
	item_stack.item.scale = Vector2(min(sx, sy), min(sx,sy))
