class_name Unit extends Node

var members: Mob = null

func insert(mob: Mob):
	if members == null:
		members = mob
		mob.previous_in_unit = null
		mob.next_in_unit = null
		return
	var current_mob = members
	while current_mob.next_in_unit:
		current_mob = current_mob.next_in_unit
		
	current_mob.next_in_unit = mob
	mob.next_in_unit = null
	mob.previous_in_unit = current_mob
	mob.follow(current_mob)
	
func remove(mob: Mob):
	if members == null: return 
	
	var current_mob = members
	while current_mob.next_in_unit:
		if current_mob == mob:
			mob.previous_in_unit = mob.next_in_unit.next_in_unit
			mob.next_in_unit = null
			mob.previous_in_unit = null
			mob.idle()
			return
		current_mob = current_mob.next_in_unit
	print_debug("mob not found in unit " + mob.mob_name)

func order(order: String):
	if members == null: return 
	
	var current_mob = members
	while current_mob.next_in_unit:
		current_mob.order(order)
