extends State



@export var investigate_pos_period = 0.1

var investigation_position: Vector2 = Vector2.ZERO
var navigation: NavigationAgent2D
var timer: Timer
var active: bool = false
signal set_desired_direction
signal investigation_location_reached
func enter():
	active = true
	start_investigating()
	set_desired_direction.connect(fsm.mob._on_set_desired_direction)
	investigation_location_reached.connect(fsm.mob._on_investigation_location_reached)
	navigation = fsm.mob.navigation
	
func start_investigating():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = investigate_pos_period
	timer.timeout.connect(give_mob_investigate_direction)
	timer.start()
	
func investigate_at(position: Vector2):
	investigation_position = position
	give_mob_investigate_direction()
		
func give_mob_investigate_direction():
	if !active: return
	navigation.target_position = investigation_position
	navigation.target_desired_distance = 5.0
	if was_investigation_location_reached():
		emit_signal("investigation_location_reached")
		timer.stop()
		return
	
 
func was_investigation_location_reached() -> bool:
	if fsm.mob.global_position.distance_to(investigation_position) < navigation.target_desired_distance: return true
	return false
		

func exit():
	active = false
