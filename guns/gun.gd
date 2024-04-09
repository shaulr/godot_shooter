extends Area2D
@onready var sprite = $"weaponPivot/mp-40"
@onready var shootingPoint = %shootingPoint
var keepShooting = false;
@onready var audioPlayer = $AudioStreamPlayer2D
@onready var weaponPivot = $weaponPivot
@onready var shootSound = "res://art/shoot1911.mp3"
@onready var game = $"/root/Game"
@onready var muzzleflash = $"weaponPivot/mp-40/shootingPoint/muzzleflashplayer"
var gun_direction = "down"
@onready var knocback_anim = $knockbackPlayer
func get_gun_rotation():
	if rotation_degrees > 270:
		rotation_degrees = -90
	elif rotation_degrees < -90:
		rotation_degrees = 270
	return rotation_degrees

func pointGun():
	var aimPos = get_viewport().get_mouse_position()
	var dir = weaponPivot.global_position.direction_to(aimPos)
	var camera = game.player.camera
	var cameraPos = camera.get_screen_center_position() - get_viewport().get_visible_rect().size/2

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
	#if current_rotation >= 45 and current_rotation <= 135 and gun_direction != "up":
		#gun_direction = "up"
		#game.player.look("up")
		#print_debug(current_rotation)
	#elif current_rotation >= 135 and current_rotation <= 225 and gun_direction != "left":
		#gun_direction = "left"
		#game.player.look("left")
		#print_debug(current_rotation)
	#elif current_rotation >= 225 and current_rotation <= 315 and gun_direction != "down":
		#gun_direction = "down"
		#game.player.look("down")
		#print_debug(current_rotation)
	#elif gun_direction != "right":
		#gun_direction = "right"
		#game.player.look("right")
		#print_debug(current_rotation)
		#


func _physics_process(delta):
	pointGun()
		
func shoot():
	muzzleflash.play("flash2")
	gun_knock()
	const BULLET = preload("res://guns/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = shootingPoint.global_position
	new_bullet.global_rotation = shootingPoint.global_rotation	
	shootingPoint.add_child(new_bullet)
	$AudioStreamPlayer2D.play()
		
func _unhandled_input(event):
	if (event is InputEventMouseButton):
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			keepShooting = true
		elif  !event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			keepShooting = false
			
func gun_knock():
	knocback_anim.play("knocback")

func _on_timer_timeout():
	if(keepShooting):
		shoot()
