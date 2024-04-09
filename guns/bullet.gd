extends Area2D
@export var speed = 300.0
@export var range = 1200
var travelled_distance = 0
@export var lastVelocity: Vector2

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	var velocity = direction * speed * delta
	position += velocity
	travelled_distance = speed * delta
	if travelled_distance > range:
		queue_free()
	lastVelocity = velocity

func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
	if body.has_method("knockback"):
		body.knockback(lastVelocity)
