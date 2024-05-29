extends Panel

class_name ItemStack
@onready var item: Sprite2D = $item
@onready var amount_label: Label = $amount_label
var inventory_slot: InventorySlot

func update():
	if !inventory_slot || !inventory_slot.item: return

	item.visible = true
	item.texture = inventory_slot.item.scene.texture

	amount_label.visible = true
	amount_label.text = str(inventory_slot.amount)
	

