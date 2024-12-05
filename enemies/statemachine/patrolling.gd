extends State


signal set_desired_direction
@export var patrol_pos_wait = 5
@export var patrol_range = 150
var patrol_position: Vector2
var navigation: NavigationAgent2D

var active: bool = false
var timer: Timer

func enter():
	print_debug("entered patrolling " + fsm.mob.name)

	active = true
	navigation = fsm.mob.navigation
	patrol_position = fsm.mob.global_position
	start_patrolling()
	
	navigation.target_reached.connect(on_target_reached)


func start_patrolling():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = patrol_pos_wait
	timer.timeout.connect(give_mob_patrol_direction)
	timer.start()
	give_mob_patrol_direction()
	
func give_mob_patrol_direction():
	if !active: return
	#var patrol_towards = (patrol_position + random_vector())
	#var desired_direction = (patrol_towards - fsm.mob.global_position).normalized()
	#emit_signal("set_desired_direction", desired_direction)
	navigation.target_position = (patrol_position + random_vector())
	navigation.target_desired_distance = 5.0
	navigation.get_next_path_position()
	
func on_target_reached():
	give_mob_patrol_direction()
	
func random_vector() -> Vector2:
	return Vector2(randf_range(-patrol_range, patrol_range), randf_range(-patrol_range, patrol_range))
	
func exit():
	active = false
	if timer: timer.stop()
