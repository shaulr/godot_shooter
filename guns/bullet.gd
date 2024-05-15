extends Area2D
@export var speed = 300.0
@export var range = 200
var travelled_distance = 0
@export var lastVelocity: Vector2
var hasHit = false
var damage = 10
@onready var sprite = $Sprite2D

func _ready():
	sprite.visible = true
	
func get_damage() -> int:
	return damage 	
	
func _physics_process(delta):
	if hasHit: return
	var direction = Vector2.RIGHT.rotated(rotation)
	var velocity = direction * speed * delta
	position += velocity
	travelled_distance += speed * delta
	if travelled_distance > range:
		hasHit = true
		$bulletEffectPlayer.play("boom")
		await $bulletEffectPlayer.animation_finished
		queue_free()
	lastVelocity = velocity

func _on_body_entered(body):
	if hasHit: return
	hasHit = true
	if body.has_method("knockback"):
		body.knockback(lastVelocity/4)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	if body.has_method("getIsDead"):
		sprite.visible = false
		$bulletEffectPlayer.play("splat")
		if body.getIsDead(): 
			queue_free()
			return
	else:
		sprite.visible = false
		$bulletEffectPlayer.play("boom")

	await $bulletEffectPlayer.animation_finished
	queue_free()

