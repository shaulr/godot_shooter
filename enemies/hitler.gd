extends CharacterBody2D
@onready var animations = $AnimationPlayer
var isDead: bool = false
@onready var game = $"/root/Game"
@onready var navigation = $NavigationAgent2D
@onready var walk = $walk
@onready var death = $death
@onready var deathAudio = $AudioStreamPlayer2D

func updateAnimation():
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
	var direction = global_position.direction_to(game.player.global_position) 
	
	#var nextPosition = navigation.get_next_path_position()
	#var direction = global_position.direction_to(nextPosition)
	velocity = direction * 30
	move_and_slide()
	updateAnimation()

	
func makePath():
	navigation.target_position = game.player.global_position

func _on_timer_timeout():
	makePath()

func take_damage():
	isDead = true
	game.mob_killed()
	walk.visible = false
	death.visible = true
	deathAudio.play()
	animations.play("death")
	await animations.animation_finished
	queue_free()

