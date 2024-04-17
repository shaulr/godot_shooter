extends Area2D
@onready var sprite = $"weaponPivot/mp-40"
@onready var shootingPoint = %shootingPoint
var trigger_pressed = false;
@onready var audioPlayer = $AudioStreamPlayer2D
@onready var weaponPivot = $weaponPivot
@onready var shootSound = "res://art/shoot1911.mp3"
@onready var game = $"/root/Game"
@onready var muzzleflash = $"weaponPivot/mp-40/shootingPoint/muzzleflashplayer"
var gun_direction = "down"
@onready var knocback_anim = $knockbackPlayer
var agros_enemies = false
var gun_noise_level = 300
signal shooting_sound(noise: int)
	
func gun_agros_enemies(agros: bool):
	agros_enemies = agros

func get_gun_rotation():
	if rotation_degrees > 270:
		rotation_degrees = -90
	elif rotation_degrees < -90:
		rotation_degrees = 270
	return rotation_degrees

func pointGun(aimPos: Vector2, correct_for_camera: bool):
	var dir = weaponPivot.global_position.direction_to(aimPos)
	var cameraPos = Vector2.ZERO
	if correct_for_camera:
		var camera = game.player.camera
		cameraPos = camera.get_screen_center_position() - get_viewport().get_visible_rect().size/2

	var current_rotation = get_gun_rotation()
	if current_rotation > 90:
		sprite.flip_v = true
		sprite.offset.y = -100
		position.y = -10
		position.x = 0
	else:
		sprite.flip_v = false
		sprite.offset.y = 0
		position.y = -10
		position.x = 0
	look_at(aimPos + cameraPos)
		
func shoot():
	emit_signal("shooting_sound", gun_noise_level)
	muzzleflash.play("flash2")
	gun_knock()
	const BULLET = preload("res://guns/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = shootingPoint.global_position
	new_bullet.global_rotation = shootingPoint.global_rotation	
	shootingPoint.add_child(new_bullet)
	$AudioStreamPlayer2D.play()
		
func press_trigger():
	shoot()
	trigger_pressed = true
	
func release_trigger():
	trigger_pressed = false

func gun_knock():
	knocback_anim.play("knocback")

func _on_timer_timeout():
	if(trigger_pressed):
		shoot()
