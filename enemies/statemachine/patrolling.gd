extends Node

var fsm: StateMachine

signal set_desired_direction
@export var patrol_pos_wait = 5
@export var patrol_range = 50
var patrol_position: Vector2

func enter():
	patrol_position = fsm.mob.global_position
	start_patrolling()
	set_desired_direction.connect(fsm.mob._on_set_desired_direction)
	

func start_patrolling():
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = patrol_pos_wait
	timer.timeout.connect(give_mob_patrol_direction)
	timer.start()
	give_mob_patrol_direction()
	
func give_mob_patrol_direction():
	var patrol_towards = (patrol_position + random_vector())
	var desired_direction = (patrol_towards - fsm.mob.global_position).normalized()
	emit_signal("set_desired_direction", desired_direction)

	
func random_vector() -> Vector2:
	return Vector2(randf_range(-patrol_range, patrol_range), randf_range(-patrol_range, patrol_range))
	
func exit(next_state):
	fsm.change_to(next_state)

