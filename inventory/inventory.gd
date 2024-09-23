extends Resource

class_name Inventory

@export var slots: Array[InventorySlot]
signal updated
signal use_item

func insert(collectible: Collectible):
	var item_slots = slots.filter(func(slot): return slot.item == collectible.item and !collectible.is_equipable)
	if !item_slots.is_empty(): item_slots[0].amount += 1
	else: 
		var empty_slots = slots.filter(func(slot): return slot.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = collectible.item
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
	var item_to_use : Collectible = null
	if ResourceLoader.exists(slot.item.scene_path) :
		item_to_use = ResourceLoader.load(slot.item.scene_path).instantiate()
		if item_to_use:
			use_item.emit(item_to_use)
			if item_to_use.is_consumable:
				if slot.amount > 1:
					slot.amount -= 1
					updated.emit()
					return
				remove_at_index(index)
	
