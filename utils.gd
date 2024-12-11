class_name Utils extends Node

static func sum_navpath(arr: Array):
	var result = 0
	var previous = Vector2.ZERO
	if arr.size() == 0: return 0
	for i in arr:
		if previous != Vector2.ZERO:
			result += previous.distance_to(i)
		previous = i
	return result

static func is_friendly(node: Node):
	if node == Game.get_player(): return true
	if !( "is_friendly") in node: 
		print_debug("node does not have is_friendly " + node.name)
		return true
	return node.is_friendly
