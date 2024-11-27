extends Node

var fsm: StateMachine
signal set_desired_direction
@export var chase_update_period = 0.1
var navigation: NavigationAgent2D
var to_follow

func enter():
	start_following()
	fsm.mob.add_child(navigation)
	set_desired_direction.connect(fsm.mob._on_set_desired_direction)
	
func start_following():
	to_follow = fsm.mob.get_follow()

	navigation = NavigationAgent2D.new()
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = chase_update_period
	timer.timeout.connect(give_mob_chase_direction)
	timer.start()
	give_mob_chase_direction()
	
func give_mob_chase_direction():
	var desired_direction = Vector2.ZERO
	navigation.target_position = to_follow.global_position
	desired_direction = navigation.get_next_path_position() - fsm.mob.global_position
	desired_direction = desired_direction.normalized()

	emit_signal("set_desired_direction", desired_direction)

	

func exit(next_state):
	fsm.change_to(next_state)
