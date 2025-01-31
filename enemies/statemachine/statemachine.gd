extends Node

class_name StateMachine

var current_state: Object

var history = []
var states = {}
var mob: Mob
enum InitialStates{idle, patrolling}

func _ready():
	mob = get_parent_of_type("Mob")
	for state in get_children():
		if state.name == "State" : continue
		state.fsm = self
		states[state.name] = state
		#if current_state:
			#remove_child(state)
		#else:
			#current_state = state
	#if current_state: current_state.enter()
func initial_state(state: InitialStates):
	var state_name: String = InitialStates.find_key(state)

	current_state = states[state_name]
	current_state.enter()
	
func get_parent_of_type(_type: String) -> Node:
	var parent = get_parent()
	while !parent.has_method("is_hostile_mob"):
		parent = parent.get_parent()
	return parent

func change_to(state_name):
	#print_debug("entered %s mob: %s" %[state_name, mob.name])

	if current_state.name == state_name: return
	history.append(current_state.name)
	current_state.exit()
	current_state = states[state_name]
	current_state.enter()

func back():
	if history.size() > 0:
		set_state(history.pop_back())

func set_state(state_name):
	remove_child(current_state)
	current_state = states[state_name]
	add_child(current_state)
	current_state.enter()

func get_current_state() -> String:
	return current_state.name
