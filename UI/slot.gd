extends Panel

@onready var background: Sprite2D = $background
@onready var item: Sprite2D = $CenterContainer/Panel/item
@onready var amount_label: Label = $CenterContainer/Panel/amount_label
func update(slot: InventorySlot):
	if !slot.item :
		background.frame = 0
		item.visible = false
		amount_label.visible = false
	else: 
		background.frame = 1
		item.visible = true
		item.texture = slot.item.texture
		scale()
		amount_label.visible = true
		amount_label.text = str(slot.amount)

func scale():
	var area_size = background.texture.get_size() * 3/4
	var texture_size = item.texture.get_size()
	var sx = area_size.x / texture_size.x
	var sy = area_size.y / texture_size.y
	item.scale = Vector2(min(sx, sy), min(sx,sy))
