extends Area2D
@onready var sprite = $"weaponPivot/mp-40"
@onready var shootingPoint = %shootingPoint
var keepShooting = false;
@onready var audioPlayer = $AudioStreamPlayer2D
@onready var weaponPivot = $weaponPivot
@onready var shootSound = "res://art/shoot1911.mp3"
func pointGun():
	var aimPos = get_viewport().get_mouse_position()
	var dir = weaponPivot.global_position.direction_to(aimPos)
	if dir.x < 0:
		sprite.flip_v = true
	else:
		sprite.flip_v = false
	look_at(aimPos)

func _physics_process(delta):
	pointGun()
		
func shoot():
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
			


func _on_timer_timeout():
	if(keepShooting):
		shoot()
