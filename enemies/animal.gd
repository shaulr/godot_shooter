extends CharacterBody2D
@onready var animations = %AnimatedSprite2D

var lastDirection = "down"
var desired_direction = Vector2.ZERO
var speed = 10
var acceleration = 7
const  STEERING_FORCE = 0.1
@export var patrol_pos_wait = 5
@export var patrol_range = 10
@export var health: int = 10
var is_dead: bool = false
var patrol_position: Vector2
var action = "walk_"
@onready var collision = $CollisionShape2D
func _ready():
	patrol_position = global_position
	start_patrolling()
	
func _physics_process(delta: float) -> void:
	if is_dead: return
	var steering_force = desired_direction*speed - velocity
	velocity = velocity  + (steering_force * STEERING_FORCE)
	updateAnimation()
	if action == "walk_":
		move_and_slide()


func updateAnimation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:		
		var direction = "down"
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		elif velocity.y < 0: direction = "up"
		animations.play(action + direction)



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
	desired_direction = (patrol_towards - global_position).normalized()
	walk_or_eat()
	
func random_vector() -> Vector2:
	return Vector2(randf_range(-patrol_range, patrol_range), randf_range(-patrol_range, patrol_range))
	
func walk_or_eat():
	if randi_range(0, 3) == 0:
		action = "eat_"
	else:
		action = "walk_"

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		is_dead = true
		collision.disabled = true    # disable

		animations.play("splat")
		await animations.animation_finished
		queue_free()
