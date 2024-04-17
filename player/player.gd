extends CharacterBody2D

@onready var animations = $AnimationPlayer

const SPEED = 1.0
var isAttacking: bool = false
@export var lastAnimDirection: String = "down"
@onready var game = $"/root/Game"
@onready var camera = $followcam
const MAX_HEALTH = 100
var current_health = MAX_HEALTH
@export var knocbackPower = 1000
@onready var audioPlayer = $AudioStreamPlayer2D
@onready var effectsPlayer = $effects
@onready var hurtimer = $hurttimer
@onready var gun = $gun
var hurting = false;

func handleInput():
	var moveDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDir * SPEED
	move_and_collide(moveDir * SPEED)

func take_damage(damage: int):
	hurting = true
	current_health -= damage
	effectsPlayer.play("hurtblink")
	hurtimer.start()
	$hurtsound.play()
	await hurtimer.timeout
	effectsPlayer.play("RESET")
	hurting = false
	
func _physics_process(delta):
	gun.pointGun(get_viewport().get_mouse_position(), true)
	update_health()
	updateAnimation()
	handleInput()

func look(direction: String):
	self.direction = direction

func updateAnimation():
	if isAttacking: return
	var direction = "down"
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
		if direction != lastAnimDirection:
			animations.play("RESET")
			lastAnimDirection = direction

	else:
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		elif velocity.y < 0: direction = "up"
		animations.play("walk" + direction)
		lastAnimDirection = direction
		
func update_health():
	var healthbar = $health_bar
	healthbar.value = current_health
	if current_health == 100:
		healthbar.visible = false
	else:
		healthbar.visible = true
	if current_health <= 0:
		die()
		
func die():
	restart_application()
	
func _ready():
	game.player = self
	gun.gun_agros_enemies(true)
	
func restart_application():
	get_tree().reload_current_scene()
	
func _on_hurtbox_area_entered(area):
	if area.get_parent().has_method("getIsDead"):
		if area.get_parent().getIsDead(): return
	if area.get_parent().has_method("get_damage"):
		take_damage(area.get_parent().get_damage())

func doing_good():
	$laugh.play()

func _unhandled_input(event):
	if (event is InputEventMouseButton):
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			gun.press_trigger()
		elif  !event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			gun.release_trigger()
func getIsDead() -> bool:
	return false
	
func knockback(enemyVeocity: Vector2):
	if hurting: return
	var knockbackDirection = enemyVeocity.normalized() * knocbackPower
	velocity = knockbackDirection
	move_and_slide()




