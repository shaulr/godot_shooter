extends State
var radius: float = 30.0
var angle: float
var speed: float = 1.5
var isScanning = false
var center: Vector2
var timer: Timer
var scan_pos_wait: float = 3.0
var counter = 0
func enter():
	angle = fsm.mob.rotation
	center = fsm.mob.global_position
	isScanning = true 
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = scan_pos_wait
	timer.timeout.connect(give_mob_scan_direction)
	timer.start()
	
func give_mob_scan_direction():
	if !isScanning: return
	angle += speed
	var x_pos = sin(angle)
	var y_pos = cos(angle)
	fsm.mob.navigation.target_desired_distance = 5.0
	fsm.mob.navigation.target_position = Vector2(center.x + radius*x_pos, center.y + radius*y_pos)
	if counter >= 5: fsm.change_to("patrolling")
	counter += 1
	

func exit():
	isScanning = false
