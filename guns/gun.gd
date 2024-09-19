extends Area2D
@onready var sprite = $"weaponPivot/sprite"
@onready var shootingPoint = %shootingPoint
var trigger_pressed = false;
@onready var audio_player = %AudioStreamPlayer2D
@onready var shootSound = "res://art/shoot1911.mp3"
@onready var muzzleflash = %muzzleflashplayer
var gun_direction = "down"
@onready var knocback_anim = $knockbackPlayer
var agros_enemies = false
var gun_noise_level = 300
@export var item: Item
var sprite_scale_factor: float
var muzzle_position: Vector2
	
func _ready():
	sprite.texture = item.texture
	scale()
	find_muzzle()
	
func scale():
	var area_size = item.maxTextureSize * 3/4
	var texture_size = item.texture.get_size()
	var sx = area_size.x / texture_size.x
	var sy = area_size.y / texture_size.y
	sprite_scale_factor = min(sx, sy)
	sprite.scale = Vector2(sprite_scale_factor, sprite_scale_factor)
	
func find_muzzle():
	var image = sprite.texture.get_image()
	for column in range(image.get_width() - 1, -1, -1):
		for row in range(image.get_height() - 1, -1, -1):
			if image.get_pixel(column, row).a8 == 255:
				print("found non-opaque at (%d, %d)" % [column, row])
				muzzle_position = Vector2(column, row)
				shootingPoint.position = muzzle_position
				return
			
			#if image.get_pixel(column, row).a8 == 0:
				#print("found non-opaque at (%d, %d)" % [column, row])
				#return
				
func gun_agros_enemies(agros: bool):
	agros_enemies = agros

func get_gun_rotation():
	if rotation_degrees > 270:
		rotation_degrees = -90
	elif rotation_degrees < -90:
		rotation_degrees = 270
	return rotation_degrees

func pointGun(aimPos: Vector2, correct_for_camera: bool):
	var cameraPos = Vector2.ZERO
	if correct_for_camera && Game.level_has_camera():
		var camera = Game.current_level.camera
		cameraPos = camera.get_screen_center_position() - get_viewport().get_visible_rect().size/2

	var current_rotation = get_gun_rotation()
	if current_rotation > 90:
		sprite.flip_v = true
		#sprite.offset.y = -100
		shootingPoint.position.y = muzzle_position.y + 5
		position.y = -10
		position.x = 0
	else:
		sprite.flip_v = false
		#sprite.offset.y = 0
		shootingPoint.position.y = muzzle_position.y - 6
		position.y = -10
		position.x = 0
	look_at(aimPos + cameraPos)
		
func shoot():
	#Game.current_level.emit_signal("shooting_sound", gun_noise_level, global_position)
	Game.current_level.sound(gun_noise_level, global_position)

	%muzzleflashplayer.play("flash2")
	audio_player.play()
	gun_knock()
	const BULLET = preload("res://guns/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = shootingPoint.global_position
	new_bullet.global_rotation = shootingPoint.global_rotation	
	shootingPoint.add_child(new_bullet)

		
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
