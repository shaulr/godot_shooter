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
	
func start(quest: String):
	self.quest_name = quest
	state = RUNNING
	#get_tree().paused = false
	
	QuestManager.add_quest(quest_name,quest_resource)

	
func quest_complete(quest):
	state = WIN
	$Complete.text += "\n Money " + str(quest.quest_rewards.money)
	$Complete.show()
	print_debug("quest_complete" + quest)
	#get_tree().paused = true
	
func quest_failed(n):
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
			Game.current_level.update_label(text)
		QuestManager.CALLABLE_STEP:
			print(step)
			if step.callable.begins_with("Dialogic.start"):
				in_conversation = true
				
			QuestManager.progress_quest(step.quest_id,step.id)
		QuestManager.ACTION_STEP:
			print(step)

func step_updated(step):
	print_debug("step_updated" + step.details)
	QuestManager.progress_quest(step.quest_id,step.id)
	
func step_complete(step):
	print_debug("step complete" + step.details)
	
func player_met(mob):
	if "mob_name" in mob:
		print_debug(mob.mob_name)
		mob.talk_to_player()
		var meta_data = current_step.meta_data
		if ! "quest_type" in meta_data:
			return
		if meta_data.quest_type == "meet" and meta_data.who == mob.mob_name:
			QuestManager.progress_quest(current_step.quest_id,current_step.id)

func _on_dialogic_timeline_ended():
	if current_step.current_step.meta_data.quest_type == "meet" && in_conversation:
		QuestManager.progress_quest(current_step.quest_id,current_step.id)
