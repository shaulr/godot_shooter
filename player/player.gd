extends CharacterBody2D
class_name Player
@onready var animations = $AnimationPlayer

const SPEED = 1.0
var isAttacking: bool = false
@export var lastAnimDirection: String = "down"
@export var MAX_HEALTH = 100
@onready var current_health = 100
 
@export var knocbackPower = 1000

@onready var effectsPlayer = $effects
@onready var hurtimer = $hurttimer
@onready var gun = $gun
@onready var knife = $knife
@onready var sprite = $Sprite2D
@export var inventory: Inventory
@onready var collider = $CollisionShape2D
var unit: Mob = null
var hurting = false
var isStabbing = false
var isDead = false 


func _enter_tree():
	Game.set_player(self)
	Game.saver_loader.player_loaded_callback(self)
	print_debug("_enter_tree")
	
func _exit_tree():
	print_debug("_exit_tree")
	
func on_pre_load():
	print_debug("on_pre_load")
	get_parent().remove_child(self)
	queue_free()

func deserialize_player(data: PlayerData, player: Player):
	player.global_position = data.position
	player.current_health = data.current_health

	
func serialize_player() -> PlayerData:
	var data = PlayerData.new()
	data.position = global_position
	data.scene_path = scene_file_path
	data.current_health = current_health
	
	return data
	
func _input(event):
	if event.is_action_pressed("stab"):
		stab()
	elif event.is_action_pressed("throw"):
		throw_bomb()
	#handleInput()

func throw_bomb():
	const GRENADE = preload("res://guns/bomb.tscn")
	var new_bomb = GRENADE.instantiate()
	new_bomb.global_position = global_position
	Game.current_level.add_child(new_bomb)
	new_bomb.throw_at(get_global_mouse_position())

func handleInput(_delta: float):
	var moveDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDir * SPEED
	move_and_collide(moveDir * SPEED)

func get_size() -> Vector2:
	return collider.shape.size
	
func stab():
	isStabbing = true
	gun.visible = false
	knife.visible = true
	knife.stab(lastAnimDirection)
	await knife.stabPlayer.animation_finished
	knife.visible = false
	gun.visible = true
	isStabbing = false

func take_damage(damage: int):
	hurting = true
	current_health -= damage
	effectsPlayer.play("hurtblink")
	hurtimer.start()
	$hurtsound.play()
	await hurtimer.timeout
	effectsPlayer.play("RESET")
	hurting = false
	
func heal(amount: int):
	current_health += amount
	current_health = min(current_health, MAX_HEALTH)
	update_health()
	
func use_item(item: Collectible):
	if item.is_equipable:
		equip(item)
	elif item.is_consumable:
		heal(item.get_healing())
	
func _physics_process(delta):
	if isDead: return
	gun.pointGun(get_viewport().get_mouse_position(), true)
	update_health() 
	updateAnimation()
	handleInput(delta)

func look(direction: String):
	self.direction = direction

func updateAnimation():
	if isAttacking: return
	var direction = "down"
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
		if direction != lastAnimDirection:
			animations.play("RESET")
			lastAnimDirection = direction

	else:
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		elif velocity.y < 0: direction = "up"
		animations.play("walk" + direction)
		lastAnimDirection = direction
		
func update_health():
	var healthbar = $health_bar
	healthbar.value = current_health  
	if current_health == 100:
		healthbar.visible = false
	else:
		healthbar.visible = true
	if current_health <= 0:
		die()
		
func die():
	isDead = true

	current_health = MAX_HEALTH
	Game.game_over()

func _ready():
	current_health = MAX_HEALTH
	inventory.use_item.connect(use_item)
	gun.gun_agros_enemies(true)
	
func restart_application():
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
	
func _on_hurtbox_area_entered(area):
	if "is_friendly" in area.get_parent():
		if area.get_parent().is_friendly:
			CampaignManager.player_met(area.get_parent())
			return
	if area.has_method("collect"):
		if area.is_consumable:
			if area.has_method("get_healing") and current_health < MAX_HEALTH:
				current_health = current_health + area.get_healing()
				if current_health > MAX_HEALTH:
					current_health = MAX_HEALTH
				#area.collect(inventory)
				get_parent().remove_child(area)
				area.queue_free()
				return
		elif area.is_collectible:
			area.collect(inventory)
			return
	if isStabbing:
		if area.get_parent().has_method("get_direction"):
			var body_dir = area.get_parent().get_direction()
			if body_dir == lastAnimDirection:
				print_debug("backstab")
				area.get_parent().take_damage(-1) #backstab instakill
			else:
				print_debug("stab")
				area.get_parent().take_damage(knife.get_damage())
	else:
		if area.get_parent().has_method("getIsDead"):
			if area.get_parent().getIsDead(): return
		if area.get_parent().has_method("get_damage"):
			take_damage(area.get_parent().get_damage())

func doing_good():
	$laugh.play()

func _unhandled_input(event):
	if (event is InputEventMouseButton):
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			gun.press_trigger()
		elif  !event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			gun.release_trigger()
func getIsDead() -> bool:
	return false
	
func knockback(enemyVeocity: Vector2):
	if hurting: return
	var knockbackDirection = enemyVeocity.normalized() * knocbackPower
	velocity = knockbackDirection
	move_and_slide()

func _draw():
	pass

func equip(item: Collectible):
	gun.equip(item)
	




#
#
#func _on_draw():
	##if Input.is_action_pressed("dash"):
	#var length = 100
	#var normalized = (get_viewport().get_mouse_position() - position).normalized()
	#var target = global_position + normalized * length
	#draw_line(position, target, Color(255, 0, 0, 0.5), 3, true)



func _on_hitbox_body_entered(body):
	if "is_friendly" in body && body.is_friendly:
		CampaignManager.player_met(body)# Replace with function body.
