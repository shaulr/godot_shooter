extends Area2D
@export var speed = 300.0
@export var range = 1200
var travelled_distance = 0
@export var lastVelocity: Vector2
var hasHit = false

func _physics_process(delta):
	if hasHit: return
	var direction = Vector2.RIGHT.rotated(rotation)
	var velocity = direction * speed * delta
	position += velocity
	travelled_distance = speed * delta
	if travelled_distance > range:
		queue_free()
	lastVelocity = velocity

func _on_body_entered(body):
		
	if body.has_method("getIsDead"):
		$bulletEffectPlayer.play("splat")
		if body.getIsDead(): return
	else:
		$bulletEffectPlayer.play("boom")
	hasHit = true
	await $bulletEffectPlayer.animation_finished
	

	if body.has_method("take_damage"):
		body.take_damage()
	if body.has_method("knockback"):
		body.knockback(lastVelocity)
	queue_free()
