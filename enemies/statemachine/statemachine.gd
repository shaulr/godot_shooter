extends Node

class_name StateMachine

var current_state: Object

var history = []
var states = {}
var mob: CharacterBody2D

func _ready():
	mob = get_parent_of_type("CharacterBody2D")
	for state in get_children():
		state.fsm = self
		states[state.name] = state
		if current_state:
			remove_child(state)
		else:
			current_state = state
	current_state.enter()

func get_parent_of_type(type: String) -> Node:
	var parent_type: String = ""
	var parent = get_parent()
	while !parent.has_method("is_hostile_mob"):
		parent = parent.get_parent()
	return parent

func change_to(state_name):
	history.append(current_state.name)
	set_state(state_name)

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
