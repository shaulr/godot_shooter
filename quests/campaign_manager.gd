class_name CampaignMgr
extends Node
@export var quest_name = ""
var quest_resource:QuestResource
var current_level: Node
enum {
	START,
	RUNNING,
	LOSE,
	WIN
}
var state = START
var current_step: Dictionary
var in_conversation: bool = false
var first_step: bool = true
var quest_info: String = ""

func _ready():
	quest_resource = ResourceLoader.load("res://quests/tutorial.quest")
	#Connect quest manager needed signals
	QuestManager.step_updated.connect(step_updated)
	QuestManager.step_complete.connect(step_complete)
	QuestManager.next_step.connect(next_step)
	QuestManager.quest_completed.connect(quest_complete)
	QuestManager.quest_failed.connect(quest_failed)
	Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)

func level_loaded(level: Node):
	current_level = level
	
	if current_step:
		if ! "item_name" in current_step:
			return
		var expected_level = ""
		
		var scene_loaded = level.scene_file_path
		if current_step.item_name == "level_loaded": 
			if current_step.meta_data && current_step.meta_data.level_path:
				var step_meta_data = current_step.meta_data
				expected_level = step_meta_data.level_path
				if expected_level == scene_loaded:
					QuestManager.progress_quest(current_step.quest_id, current_step.id)

	
func start(quest: String):
	self.quest_name = quest
	state = RUNNING
	#get_tree().paused = false
	first_step = true
	QuestManager.add_quest(quest_name,quest_resource)

func player_died(current_quest: String):
	QuestManager.remove_quest(current_quest)
	
func quest_complete(quest):
	state = WIN
	#$Complete.text += "\n Money " + str(quest.quest_rewards.money)
	#$Complete.show()
	print_debug("quest_complete" + quest)
	#get_tree().paused = true
	
func quest_failed(_n):
	state = LOSE
	$GameOver.show()
	#get_tree().paused = true
	
func next_step(step):
	print_debug("next_step" + step.details)
	current_step = step
	match step.step_type:
		QuestManager.INCREMENTAL_STEP:
			#var text = "%s %02d/%02d" % [step.details,step.collected,step.required]
			#Game.current_level.update_label(text)	
			print_debug(step)		
		QuestManager.TIMER_STEP:
			var text = "%s %03d" % [step.details,step.time]
			Game.current_level.info(text)
		QuestManager.CALLABLE_STEP:
			print(step)
			if step.callable.begins_with("Dialogic.start"):
				in_conversation = true
		QuestManager.ACTION_STEP:
			if step.step_type == QuestManager.ACTION_STEP && step.meta_data.size() == 1:
				quest_info = step.details
				current_level.info(quest_info)
	if is_automatic_progress(step):
		QuestManager.progress_quest(step.quest_id,step.id)

func step_updated(step):
	print_debug("step_updated " + step.details)
	#if step.step_type == QuestManager.INCREMENTAL_STEP:
		#
		#if step.collected >= step.required:
			#QuestManager.complete_step(step.quest_id, step)
	#else:
	#if step.step_type == QuestManager.CALLABLE_STEP:
		#QuestManager.progress_quest(step.quest_id,step.id)
	if first_step:
		QuestManager.progress_quest(step.quest_id,step.id)
		first_step = false

	
func step_complete(step):
	print_debug("step complete" + step.details)


func is_automatic_progress(step) -> bool:
	match step.step_type:
		QuestManager.CALLABLE_STEP:
			return false
		QuestManager.ACTION_STEP:
			return step.meta_data.size() <= 1
	return false
	
	
func player_met(mob):
	if "mob_name" in mob:
		print_debug(mob.mob_name)
		mob.talk_to_player()
		if current_step && current_step.has("meta_data"):
			var meta_data = current_step.meta_data
			if ! "quest_type" in meta_data:
				return
			if meta_data.quest_type == "meet" and meta_data.who == mob.mob_name:
				QuestManager.progress_quest(current_step.quest_id,current_step.id)

func _on_dialogic_timeline_ended():
	#if !current_step.has('item_name'):
		#return
	#if current_step.item_name == "conversation" && in_conversation:
	if in_conversation:
		QuestManager.progress_quest(current_step.quest_id, current_step.id)
		in_conversation = false


func introduce_player_to(mob: Mob):
	if mob.mob_name == "bosko":
		Dialogic.start("zdenka_bosko_intro")


func _dialog_ended():
	QuestManager.progress_quest_by_name("Intro", "")

func item_collected(item: Collectible):
	if current_step.meta_data:
		var metadata: Dictionary = current_step.meta_data
		if metadata.has("quest_type") && metadata["quest_type"] == "pick_up":
			if metadata.has("what") && metadata["what"] == item.item.name:
				QuestManager.progress_quest(current_step.quest_id, current_step.id)

func get_quest_info() -> String:
	return quest_info
