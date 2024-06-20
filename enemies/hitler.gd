extends CharacterBody2D
@onready var animations = $AnimationPlayer
var isDead: bool = false

@onready var navigation = $NavigationAgent2D
@onready var walk = $walk
@onready var death = $death
@onready var deathAudio = $AudioStreamPlayer2D
@onready var healthbar = $healthbar
@onready var vision = $vision
@onready var gun = $gun
const  STEERING_FORCE = 0.1

var speed = 30
var acceleration = 7
const MAX_HEALTH = 100
var current_health = 100
@export var lastVelocity: Vector2
@export var knocbackPower = 50
var can_see_player = false
var is_agro = false
var lastDirection = "down"
var desired_direction = Vector2.ZERO
@export var limit = 0.5
@onready var fsm = $Statemachine
@onready var health_type = preload("res://droppables/health.tscn")
var rng = RandomNumberGenerator.new()
var dropped = false
func _enter_tree():
	add_to_group("game_events")
	Game.current_level.shooting_sound.connect(_on_shots_fired.bind())
	
func _ready(): 

	gun.gun_agros_enemies(true)
	vision.look_at(vision.global_position + Vector2(0, 1))

	
func on_save_data(saved_data:Array[SavedData]):
	print_debug("on_save_data")
	var data = MobData.new() as MobData
	data.position = global_position
	data.scene_path = scene_file_path
	data.speed = speed
	data.acceleration = acceleration
	data.current_health = current_health
	data.lastVelocity = lastVelocity
	data.can_see_player = can_see_player
	data.is_agro = is_agro
	data.lastDirection = lastDirection
	data.desired_direction = desired_direction
	saved_data.append(data)
	
func on_pre_load():
	print_debug("on_pre_load")
	get_parent().remove_child(self)
	queue_free()
	
func on_load(savedData: SavedData):
	if savedData is SavedCollectibleData:
		var data = savedData as SavedCollectibleData
		global_position = data.position
		speed = data.speed
		acceleration = data.acceleration
		current_health = data.current_health
		lastVelocity = data.lastVelocity
		can_see_player = data.can_see_player
		is_agro = data.is_agro
		lastDirection = data.lastDirection
		desired_direction = data.desired_direction	

func is_hostile_mob() -> bool:
	return true	

func updateAnimation():
	lastVelocity = velocity
	if isDead:
		animations.play("death")
		return
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:		
		var direction = "down"
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		elif velocity.y < 0: direction = "up"
		lastDirection = direction
		animations.play("walk" + direction)
	
func pointVision():
	vision.look_at(vision.global_position + velocity)

func get_direction() -> String:
	return lastDirection

func _physics_process(delta):
	if isDead: return
	#var direction = Vector2.ZERO
	#direction = navigation.get_next_path_position() - global_position
	#direction = direction.normalized()
	#if is_agro:
		#velocity = velocity.lerp(direction * speed, acceleration * delta)
	var steering_force = desired_direction*speed - velocity
	velocity = velocity  + (steering_force * STEERING_FORCE)
	
	update_health()
	updateAnimation()
	pointVision()
	if can_see_player and Game.get_player():
		gun.pointGun(Game.get_player().global_position, false)
	move_and_slide()

func update_velocity():
	var moveDirection =  desired_direction - position
	moveDirection = moveDirection.normalized()
	velocity = moveDirection * speed

func makePath():
	if scene_manager.player:
		navigation.target_position = Game.get_player().global_position


func _on_timer_timeout():
	makePath()

func take_damage(damage: int):
	if damage == -1:
		current_health = 0
	else:
		current_health -= damage
	is_agro = true
	if current_health <= 0:
		die()
		
func getIsDead() -> bool:
	return isDead
	
func die():
	if !isDead: Game.mob_killed()

	$CollisionShape2D.disabled = true
	$hitbox/CollisionShape2D.disabled = true
	update_health()
	isDead = true
	drop_loot()
	walk.visible = false
	death.visible = true
	deathAudio.play()
	animations.play("death")
	await animations.animation_finished
	queue_free()
	
func drop_loot():
	if isDead and dropped: return
	dropped = true
	var health = health_type.instantiate()
	if rng.randf() <= health.get_drop_chance():

		Game.current_level.add_child(health)
		health.global_position = global_position
	
func update_health():
	healthbar.value = current_health
	if current_health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true

func get_damage() -> int:
	return 10

func knockback(enemyVeocity: Vector2):
	var knockbackDirection = enemyVeocity.normalized() * knocbackPower
	velocity = knockbackDirection
	move_and_slide()
	
func _on_vision_is_visible(is_visible: bool):
	if is_visible and !isDead:
		can_see_player = true
		gun.press_trigger()
		is_agro = true
		if fsm.get_current_state() != "chase":
			fsm.change_to("chase")
	else:
		can_see_player = false
		gun.release_trigger()

func sum_navpath(arr: Array):
	var result = 0
	var previous = Vector2.ZERO
	if arr.size() == 0: return 0
	for i in arr:
		if previous != Vector2.ZERO:
			result += previous.distance_to(i)
		previous = i
	return result

func _on_shots_fired(loudness: int, sound_pos: Vector2):
	navigation.target_position = sound_pos
	navigation.get_next_path_position()
	var navigation_distance = sum_navpath(navigation.get_current_navigation_path())
	if navigation_distance != 0 and navigation_distance <= loudness:
		fsm.change_to("investigate")
	
func _on_set_desired_direction(direction: Vector2):
	desired_direction = direction

func _on_investigation_location_reached():
	fsm.change_to("patrolling")

