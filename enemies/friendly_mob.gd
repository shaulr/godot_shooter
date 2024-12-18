class_name FriendlyMob extends Mob
@export_file var character_song: String

func _enter_tree():
	if mob_name == "bosko":
		Game.set_bosko(self)
	
func is_hostile_mob() -> bool:
	return false	

func play_character_song():
	if character_song && character_song.length() > 0:
		Game.play_song(character_song)
	

func _physics_process(_delta):
	if isDead: return
	
	var steering_force = desired_direction*speed - velocity
	velocity = velocity  + (steering_force * STEERING_FORCE)
	
	update_health()
	updateAnimation()
	pointVision()
	if can_see_enemy:
		if !mob_to_attack && Game.get_player():
			gun.pointGun(Game.get_player().global_position, false)
		elif mob_to_attack:
			gun.pointGun(mob_to_attack.global_position, false)

	move_and_slide()



func makePath():
	if scene_manager.player:
		navigation.target_position = Game.get_player().global_position



		
	
func _on_vision_is_visible(seen_someone: bool, mobs: Array):
	if seen_someone and !isDead:
		for mob in mobs:
			if Utils.is_friendly(mob) != is_friendly:
				can_see_enemy = true
				if mob != Game.get_player():
					mob_to_attack = mob
				if has_bombs:
					throw_bomb_at(mob.global_position)
				else:
					gun.press_trigger()
				is_agro = true
				if fsm.get_current_state() != "chase":
					fsm.change_to("chase")
	else:
		can_see_enemy = false
		mob_to_attack = null
		gun.release_trigger()
		
func talk_to_player():
	if fsm.get_current_state() == "follow":
		return
	fsm.change_to("talking")
	if is_friendly && !met_player:
		CampaignManager.introduce_player_to(self)
	
func follow(who_to_follow):
	to_follow = 	who_to_follow
	fsm.change_to("follow")
	Game.play_song(character_song)
	
	
func idle():
	fsm.change_to("patrol")
	
func get_follow():
	return to_follow
	
func is_enemy(mob: Object) -> bool:
	return mob != Game.get_player() || !mob.is_friendly()
	
func _on_shots_fired(loudness: int, sound_pos: Vector2, friendly: bool):
	pass
	

func _on_hurtbox_area_entered(area):
	if is_friendly and area == Game._player:
		CampaignManager.player_met(self)

func order(order: String):
	print_debug(mob_name + " recieved order " + order)
