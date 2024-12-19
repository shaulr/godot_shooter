extends State

signal set_desired_direction
@export var chase_update_period = 0.1
var to_follow

func enter():
	start_chasing()
	to_follow = fsm.mob.get_follow()

	set_desired_direction.connect(fsm.mob._on_set_desired_direction)

func start_chasing():
	var timer: Timer = Timer.new()

	add_child(timer)
	timer.one_shot = false
	timer.wait_time = chase_update_period
	timer.timeout.connect(give_mob_chase_direction)
	timer.start()
	give_mob_chase_direction()
	
func give_mob_chase_direction():
	if !is_instance_valid(to_follow): return
	if to_follow.has_method("location_behind"): emit_signal("set_desired_direction", to_follow.location_behind())
	else: emit_signal("set_desired_direction", to_follow.global_position)

	

func exit():
	pass
