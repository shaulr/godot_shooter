extends Node2D
@export var speed = 300.0
@export var bullet_range = 200
var travelled_distance = 0
@export var lastVelocity: Vector2
var hasHit = false
var damage = 100
@onready var sprite = $Sprite2D
@export var rotation_speed = 10.0
@export var gravity = 9.8
var target: Vector2
var direction: Vector2
@export var gun_noise_level = 500
@export var explosion_radius: float = 100.0
@onready var bombEffectsPlayer = $bombEffectsPlayer
@onready var boomAudio = $boom_audio
@onready var explosion_collision: CollisionShape2D = $explosion_collision
@onready var collision: CollisionShape2D = $collision
var exploding = false
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.visible = true
	explosion_collision.shape.radius = explosion_radius
	
func get_explosion_radius() -> float:
	return explosion_radius

func _physics_process(delta):
	if hasHit: return
	if has_hit():
		explode()
		return
	

	var velocity = direction * speed * delta
	position += velocity
	travelled_distance += speed * delta
	
	lastVelocity = velocity
	sprite.rotation += delta * rotation_speed *180/PI

func damage_arround():
	explosion_collision.disabled = false


func has_hit() -> bool:
	var distance_to_target = global_position.distance_to(target)
	if distance_to_target < 10.0: return true
	if travelled_distance > bullet_range: return true
	return false

func throw_at(target: Vector2):
	self.target = target
	direction = global_position.direction_to(target)
	bombEffectsPlayer.visible = false


func _on_body_entered(body: Node2D) -> void:
	if !exploding: return
	if body.has_method("take_damage") && exploding: 
		body.take_damage(damage)
	
	
func explode():
	explosion_collision.disabled = false
	exploding = true
	Game.current_level.sound(gun_noise_level, global_position, Utils.is_friendly(get_parent()))

	hasHit = true
	bombEffectsPlayer.visible = true
	sprite.visible = false
	bombEffectsPlayer.play("boom")
	boomAudio.play()
	await bombEffectsPlayer.animation_finished
	queue_free()
