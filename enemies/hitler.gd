extends CharacterBody2D
@onready var animations = $AnimationPlayer
var isDead: bool = false
@onready var game = $"/root/Game"
@onready var navigation = $NavigationAgent2D
@onready var walk = $walk
@onready var death = $death
@onready var deathAudio = $AudioStreamPlayer2D
@onready var healthbar = $healthbar
var speed = 30
var acceleration = 7
const MAX_HEALTH = 100
var current_health = 100
@export var lastVelocity: Vector2
@export var knocbackPower = 50

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
	


func _physics_process(delta):
	if isDead: return

	var direction = Vector2.ZERO
	direction = navigation.get_next_path_position() - global_position
	direction = direction.normalized()

	velocity = velocity.lerp(direction * speed, acceleration * delta)
	update_health()
	updateAnimation()
	move_and_slide()

func makePath():
	navigation.target_position = game.player.global_position

func _on_timer_timeout():
	makePath()

func take_damage():
	current_health -= 10

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
