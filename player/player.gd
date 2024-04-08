extends CharacterBody2D

@onready var animations = $AnimationPlayer

const SPEED = 1.0
var isAttacking: bool = false
@export var lastAnimDirection: String = "down"
@onready var game = $"/root/Game"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func handleInput():
	var moveDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDir * SPEED
	move_and_collide(moveDir * SPEED)

func _physics_process(delta):
	updateAnimation()
	handleInput()

func updateAnimation():
	if isAttacking: return
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		var direction = "down"
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		elif velocity.y < 0: direction = "up"
		animations.play("walk" + direction)
		lastAnimDirection = direction

func _ready():
	game.player = self
