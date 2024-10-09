extends Node

var fsm: StateMachine


@export var investigate_pos_period = 0.1

var investigation_position: Vector2 = Vector2.ZERO
var navigation: NavigationAgent2D

func enter():
	pass

	
func start_dialog():
	pass
	



func exit(next_state):
	fsm.change_to(next_state)

