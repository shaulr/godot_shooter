extends Button
@onready var background = $background
@onready var item_stack_gui = $CenterContainer/Panel

func update_to_slot(slot: InventorySlot):
	if !slot.item:
		item_stack_gui.visible = false
		background.frame = 0
		return
		
	item_stack_gui.inventory_slot = slot
	item_stack_gui.update()
	item_stack_gui.visible = true
	background.frame = 1
	scale()
	
func scale():
	var area_size = background.texture.get_size() * 3/4
	var texture_size = item_stack_gui.item.texture.get_size()
	var sx = area_size.x / texture_size.x
	var sy = area_size.y / texture_size.y
	item_stack_gui.item.scale = Vector2(min(sx, sy), min(sx,sy))
