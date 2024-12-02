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

@onready var bombEffectsPlayer = $bombEffectsPlayer
@onready var boomAudio = $boom_audio
@onready var explosion_collision = $explosion_collision
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.visible = true

func _physics_process(delta):
	if hasHit: return
	if global_position.distance_to(target) < 10.0:
		hasHit = true
	

	var velocity = direction * speed * delta
	position += velocity
	travelled_distance += speed * delta
	if travelled_distance > bullet_range || hasHit:
		explosion_collision.disabled = false
		hasHit = true
		bombEffectsPlayer.visible = true
		sprite.visible = false
		bombEffectsPlayer.play("boom")
		boomAudio.play()
		await bombEffectsPlayer.animation_finished
		queue_free()
	lastVelocity = velocity
	sprite.rotation += delta * rotation_speed *180/PI

func damage_arround():
	explosion_collision.enabled = true


func throw_at(target: Vector2):
	self.target = target
	direction = global_position.direction_to(target)
	bombEffectsPlayer.visible = false


func _on_body_entered(body: Node2D) -> void:
	if !hasHit: return
	if body.has_method("take_damage"): body.take_damage(damage)
