extends Control
var is_open: bool = false
signal inventory_opened 
signal inventory_closed
@onready var inventory: Inventory = preload("res://inventory/inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready():
	inventory.updated.connect(update)
	update()

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])

func open():
	visible = true
	is_open = true
	inventory_opened.emit()
	
func close():
	visible = false
	is_open = false
	inventory_closed.emit()
