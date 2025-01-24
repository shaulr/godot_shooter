class_name Mob extends CharacterBody2D
@onready var animations = $AnimationPlayer
var isDead: bool = false

var navigation: NavigationAgent2D
@onready var death = $death
@onready var deathAudio = $AudioStreamPlayer2D
@onready var healthbar = $healthbar
@onready var vision = $vision
@onready var gun = $gun
@onready var collision_shape = %CollisionShape2D
#@onready var movement: Movement = $Movement
const  STEERING_FORCE = 0.05
var to_follow
@export var speed = 30
var acceleration = 7
const MAX_HEALTH = 100
var current_health = 100
@export var lastVelocity: Vector2
@export var knocbackPower = 50
@export var is_friendly: bool
@export var has_bombs: bool = false
@export var has_gun: bool = true
@export var initial_state: StateMachine.InitialStates
enum WarSide {allied, axis, neutral}
@export var belongs: WarSide
var can_see_enemy = false
var is_agro = false
var lastDirection = "down"
var desired_direction = Vector2.ZERO
@export var limit = 0.5
@export var mob_name = "enemy"
@onready var fsm: StateMachine = $Statemachine
@onready var health_type = preload("res://droppables/health.tscn")

@export var drop_table: Array[Item]
@export var gun_table: Array[Item]
var met_player: bool = false
var rng = RandomNumberGenerator.new()
var dropped = false
var next_in_unit: Mob = null
var previous_in_unit: Mob = null
var mob_to_attack: Mob = null
@export var smoke_scene: PackedScene
var desired_vector: Vector2
func _enter_tree():
	add_to_group("game_events")
	if Game.current_level && "shooting_sound" in Game.current_level:
		Game.current_level.shooting_sound.connect(_on_shots_fired.bind())
	if mob_name == "bosko":
		Game.set_bosko(self)
	
func _ready(): 
	navigation = NavigationAgent2D.new()
	add_child(navigation)
	navigation.debug_enabled = true
	navigation.radius = 10
	navigation.path_desired_distance = 20
	gun.gun_agros_enemies(true)
	vision.look_at(vision.global_position + Vector2(0, 1))
	fsm.initial_state(initial_state)
	if !has_gun: gun.visible = false
	else: equip_gun()
	
func equip_gun():
	var gun_from_table = get_item_from_table(gun_table)
	gun.equip_item(gun_from_table)
	
func on_save_data(saved_data:Array[SavedData]):
	print_debug("on_save_data")
	var data = MobData.new() as MobData
	data.position = global_position
	data.scene_path = scene_file_path
	data.speed = speed
	data.acceleration = acceleration
	data.current_health = current_health
	data.lastVelocity = lastVelocity
	data.can_see_enemy = can_see_enemy
	data.is_agro = is_agro
	data.is_friendly = is_friendly
	data.lastDirection = lastDirection
	data.desired_direction = desired_direction
	saved_data.append(data)
	
func on_pre_load():
	print_debug("on_pre_load")
	get_parent().remove_child(self)
	queue_free()
	
func on_load(savedData: SavedData):
	if savedData is MobData:
		var data = savedData as MobData
		global_position = data.position
		speed = data.speed
		acceleration = data.acceleration
		current_health = data.current_health
		lastVelocity = data.lastVelocity
		can_see_enemy = data.can_see_enemy
		is_agro = data.is_agro
		is_friendly = data.is_friendly
		lastDirection = data.lastDirection
		desired_direction = data.desired_direction	

func is_hostile_mob() -> bool:
	return is_friendly	

func updateAnimation():
	lastVelocity = velocity
	
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
	
func get_desired_location() -> Vector2:
	return (navigation.get_next_path_position() - global_position).normalized()
	
func update_speed(_delta: float):
	if navigation.distance_to_target() < 20.0: 
		fsm.change_to("scan")
		return
	var direction = Vector2.ZERO
	if speed > 0:
		if !navigation.is_navigation_finished(): 
			#direction = navigation.get_next_path_position() - global_position
			direction = desired_vector.normalized()
			#direction = movement.pick_direction(direction)	
			#vision.set_desired_location(navigation.get_next_path_position() - global_position)
		#if is_agro:
			#velocity = velocity.lerp(direction * speed, acceleration * delta)
		var steering_force = direction * speed  * STEERING_FORCE
		if steering_force.length() > 50.0 || steering_force.length() < -50.0:
			print_debug("steering force strange")
			steering_force /= 2.0
		
		velocity += steering_force 
		if velocity.length() > speed: 
			velocity = velocity.normalized() * speed
		
func set_desired_vector(desired: Vector2):
	desired_vector = desired
		
func _physics_process(delta):
	if isDead: return
	
	update_speed(delta)
	update_health()
	updateAnimation()
	pointVision()
	if can_see_enemy:
		if !mob_to_attack && Game.get_player():
			gun.pointGun(Game.get_player().global_position, false)
		elif mob_to_attack:
			gun.pointGun(mob_to_attack.global_position, false)
	if speed > 0:
		move_and_slide()

func update_velocity():
	var moveDirection =  desired_direction - position
	moveDirection = moveDirection.normalized()
	velocity = moveDirection * speed

func _on_timer_timeout():
	pass
	#makePath()

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
	else: return
	$CollisionShape2D.set_deferred("disabled", true)         
	$hitbox/CollisionShape2D.set_deferred("disabled", true)         
	
	update_health()
	isDead = true

	#walk.visible = false
	#death.visible = true
	deathAudio.play()
	
	animations.play("death")
	await animations.animation_finished
	if speed > 0:
		drop_loot()
		queue_free()
	else:
		$sprite_top.texture = load("res://art/bunkers/bunker_round_top_down_destroyed.png")
		var _smoke = smoke_scene.instantiate()
		_smoke.position = global_position
		_smoke.rotation = global_rotation
		_smoke.emitting = true
		vision.off()
		Game.current_level.add_child(_smoke)
	
func get_item_from_table(table: Array[Item]) -> Node: 
	var total_weight: int = 0
	for item in table:
		total_weight += item.drop_weight
	if total_weight < 1: total_weight = 1
	var rnd = randi() % total_weight
	var current_weight = 0
	for item in table:
		current_weight += item.drop_weight
		if rnd <= current_weight && item.scene_path != null:
			var scene = load(item.scene_path)
			var node = scene.instantiate()
			return node
			
	return null
	
func drop_loot():
	if isDead and dropped: return
	dropped = true
	
	var node = get_item_from_table(drop_table)
	Game.current_level.add_child(node)
	node.global_position = global_position	
	
func update_health():
	healthbar.value = current_health
	if current_health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true

func get_damage() -> int:
	return 10

func knockback(enemyVeocity: Vector2):
	if isDead: return
	var knockbackDirection = enemyVeocity.normalized() * knocbackPower
	velocity = knockbackDirection
	move_and_slide()
	
func _on_vision_is_visible(vision_is_visible: bool, mobs: Array):
	if vision_is_visible and !isDead:
		for mob in mobs:
			if mob.isDead: continue
			if is_enemy(mob):
				can_see_enemy = true
				if mob != Game.get_player():
					mob_to_attack = mob
				if has_bombs:
					throw_bomb_at(mob.global_position)
				else:
					gun.press_trigger()
				is_agro = true
				if fsm.get_current_state() != "chase" && speed > 0:
					to_follow = mob
					fsm.change_to("chase")
	else:
		can_see_enemy = false
		mob_to_attack = null
		gun.release_trigger()
		if fsm.get_current_state() == "chase":
			fsm.back()
			
func throw_bomb_at(throw_position: Vector2):
	const GRENADE = preload("res://guns/bomb.tscn")
	var new_bomb = GRENADE.instantiate()
	new_bomb.global_position = global_position
	var target_distance_to_player = position.distance_to(global_position)
	if target_distance_to_player < new_bomb.get_explosion_radius():
		return
	
	Game.current_level.add_child(new_bomb)
	
	new_bomb.throw_at(throw_position)			
			
func talk_to_player():
	if fsm.get_current_state() == "follow":
		return
	fsm.change_to("talking")
	if is_friendly && !met_player:
		CampaignManager.introduce_player_to(self)
	
func follow(who_to_follow):
	to_follow = 	who_to_follow
	fsm.change_to("follow")
	
func idle():
	fsm.change_to("patrol")
	
func get_follow():
	return to_follow
	
func is_enemy(mob: Object) -> bool:
	return is_friendly != Utils.is_friendly(mob)

func _on_shots_fired(loudness: int, sound_pos: Vector2, friendly: bool):
	if friendly == is_friendly: return
	navigation.target_position = sound_pos
	navigation.get_next_path_position()
	var navigation_distance = Utils.sum_navpath(navigation.get_current_navigation_path())
	if navigation_distance != 0 and navigation_distance <= loudness:
		fsm.change_to("investigate")
		fsm.current_state.investigate_at(sound_pos)
		
func navigate_to(navigate_position: Vector2):
	navigation.target_position = navigate_position
	navigation.get_next_path_position()
	
func _on_set_desired_direction(direction: Vector2):
	desired_direction = direction

func _on_investigation_location_reached():
	fsm.change_to("scan")

func _on_hurtbox_area_entered(area):
	if is_friendly and area == Game._player:
		CampaignManager.player_met(self)

func order(recieved_order: String):
	print_debug(mob_name + " recieved order " + recieved_order)

func turn_enemy():
	is_friendly = false
