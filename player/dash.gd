class_name Dash extends Node
var inDash = false
@onready var timer = $Timer
var player: Player = null
@onready var dash_line = $Line2D
@onready var dash_raycast = $"../dashRaycast"
@onready var skull_and_bones_texture = preload("res://art/skull_and_bones.png")
var dash_range = 100
var skull_and_bones: Sprite2D

func _ready():
	skull_and_bones = Sprite2D.new()
	skull_and_bones.texture = skull_and_bones_texture
	skull_and_bones.visible = false
	skull_and_bones.scale = Vector2(0.3, 0.3)
	skull_and_bones.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	player = Game.get_player()
	player.add_child.call_deferred(skull_and_bones)
	
	
func _input(event):
	if event.is_action_pressed("dash"):
		dash()
func dash():
	inDash = true
	timer.start()

func _process(_delta):
	#if !inDash : return
	var direction = dash_line.get_global_mouse_position() - player.global_position
	direction = direction.normalized()
	var end_point = player.global_position.direction_to(player.get_global_mouse_position())
	end_point  = dash_range * direction + player.global_position
	dash_raycast.target_position = dash_raycast.to_local(end_point)
	if Input.is_action_just_pressed("dash"):
		dash_raycast.enabled = true
		if dash_line.points.size() == 0:
			dash_line.add_point(dash_raycast.global_position)
			if dash_raycast.is_colliding():
				end_point = dash_raycast.get_collision_point()
			
			dash_line.add_point(end_point)
	
	if dash_line.points.size() > 0:
		if dash_raycast.is_colliding():
			end_point = dash_raycast.get_collision_point()
			dash_line.set_point_position(dash_line.points.size()-2, dash_raycast.global_position)
			dash_line.set_point_position(dash_line.points.size()-1, dash_raycast.get_collision_point())
			if dash_raycast.get_collider().has_method("take_damage"):
				skull_and_bones.position = dash_raycast.get_collision_point()
				skull_and_bones.visible = true
				if Input.is_action_just_pressed("stab"):
					dash_to(end_point)
					player.stab()
					
					
					
		else:

			skull_and_bones.visible = false

	   
	if Input.is_action_just_released("dash"):
		#var thread = Thread.new()
		dash_raycast.enabled = false
		dash_line.clear_points()	
		dash_to(end_point) 
		# You can bind multiple argume nts to a function Callable.
		#thread.start(dash_to.bind(end_point, tween))



func dash_to(point: Vector2):
	player.animations.play("walk" + Game.get_player().vector_to_direction(point))
	var tween  = get_tree().create_tween()
	tween.connect("finished", _tween_finished)

	tween.tween_property(Game.get_player(), "position", point, 0.5 )
	inDash = false
	
func _tween_finished():
	player.animations.play("RESET")

func _on_timer_timeout():
	inDash = false
	
