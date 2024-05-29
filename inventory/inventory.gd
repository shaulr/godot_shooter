extends Resource

class_name Inventory

@export var slots: Array[InventorySlot]
signal updated
signal use_item

func insert(item: Item):
	var item_slots = slots.filter(func(slot): return slot.item == item)
	if !item_slots.is_empty(): item_slots[0].amount += 1
	else: 
		var empty_slots = slots.filter(func(slot): return slot.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = item
			empty_slots[0].amount = 1
	updated.emit()
	
func remove_slot(inventory_slot: InventorySlot):
	var index = slots.find(inventory_slot)
	if index < 0: return
	remove_at_index(index)
	updated.emit()
		
func remove_at_index(index: int):
	slots[index] = InventorySlot.new()
	updated.emit()
		
func insert_slot(index: int, inventory_slot: InventorySlot):
	slots[index] = inventory_slot
	updated.emit()

func use_item_at_index(index: int):
	if index < 0 || index >= slots.size() || !slots[index]: return
	var slot = slots[index]
	use_item.emit(slot.item)
	if slot.amount > 1:
		slot.amount -= 1
		updated.emit()
		return
		
	remove_at_index(index)
	
