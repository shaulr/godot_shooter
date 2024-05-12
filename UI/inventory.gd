extends Control
var is_open: bool = false
signal inventory_opened 
signal inventory_closed

func open():
	visible = true
	is_open = true
	inventory_opened.emit()
	
func close():
	visible = false
	is_open = false
	inventory_closed.emit()
