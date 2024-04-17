extends CharacterBody2D
@onready var animations = $AnimationPlayer
var isDead: bool = false
@onready var game = $"/root/Game"
@onready var navigation = $NavigationAgent2D
@onready var walk = $walk
@onready var death = $death
@onready var deathAudio = $AudioStreamPlayer2D
@onready var healthbar = $healthbar
@onready var vision = $vision
@onready var gun = $gun

var speed = 30
var acceleration = 7
const MAX_HEALTH = 100
var current_health = 100
@export var lastVelocity: Vector2
@export var knocbackPower = 50
var can_see_player = false
var is_agro = false

func _ready(): 
	game.player.gun.shooting_sound.connect(_on_shots_fired.bind())
	gun.gun_agros_enemies(true)
	
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
		animations.play("walk" + direction)
	
func pointVision():
	vision.look_at(vision.global_position + velocity)


func _physics_process(delta):
	if isDead: return
	var direction = Vector2.ZERO
	direction = navigation.get_next_path_position() - global_position
	direction = direction.normalized()
	if is_agro:
		velocity = velocity.lerp(direction * speed, acceleration * delta)
	
	update_health()
	updateAnimation()
	pointVision()
	if can_see_player:
		gun.pointGun(game.player.global_position, false)
	move_and_slide()

func makePath():
	navigation.target_position = game.player.global_position

func _on_timer_timeout():
	makePath()

func take_damage(damage: int):
	current_health -= damage
	is_agro = true
	if current_health <= 0:
		die()
		
func getIsDead() -> bool:
	return isDead
	
func die():
	if !isDead: game.mob_killed()
	$CollisionShape2D.disabled = true
	$hitbox/CollisionShape2D.disabled = true
	update_health()
	isDead = true
	walk.visible = false
	death.visible = true
	deathAudio.play()
	animations.play("death")
	await animations.animation_finished
	queue_free()
	
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
	if is_visible:
		can_see_player = true
		gun.press_trigger()
		is_agro = true
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

func _on_shots_fired(loudness: int):
	var navigation_distance = sum_navpath(navigation.get_current_navigation_path())
	if navigation_distance != 0 and navigation_distance <= loudness:
		is_agro = true
	
