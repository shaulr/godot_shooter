extends Node

var fsm: StateMachine

signal investigation_location_reached
signal set_desired_direction
@export var investigate_pos_period = 0.1

@onready var game = $"/root/Game"
var investigation_position: Vector2 = Vector2.ZERO
var navigation: NavigationAgent2D

func enter():
	set_desired_direction.connect(fsm.mob._on_set_desired_direction)
	navigation = NavigationAgent2D.new()
	fsm.mob.add_child(navigation)
	investigation_position = game.player.global_position
	start_investigating()
	investigation_location_reached.connect(fsm.mob._on_investigation_location_reached)
	
func start_investigating():
	navigation.target_position = game.player.global_position
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = investigate_pos_period
	timer.timeout.connect(give_mob_investigate_direction)
	timer.start()
	
func give_mob_investigate_direction():
	var desired_direction = Vector2.ZERO
	desired_direction = navigation.get_next_path_position() - fsm.mob.global_position
	desired_direction = desired_direction.normalized()
	if fsm.mob.global_position.distance_to(investigation_position) < fsm.mob.limit:
		emit_signal("investigation_location_reached")
	emit_signal("set_desired_direction", desired_direction)
	print("desired direction (%f, %f)" % [desired_direction.x, desired_direction.y])

func exit(next_state):
	fsm.change_to(next_state)

