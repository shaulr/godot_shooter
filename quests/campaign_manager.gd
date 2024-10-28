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

func _ready():
	quest_resource = ResourceLoader.load("res://quests/tutorial.quest")
	#Connect quest manager needed signals
	QuestManager.step_updated.connect(step_updated)
	QuestManager.step_complete.connect(step_complete)
	QuestManager.next_step.connect(update_ui)
	QuestManager.quest_completed.connect(quest_complete)
	QuestManager.quest_failed.connect(quest_failed)

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
	
	#get_tree().paused = true
	
func quest_failed(n):
	state = LOSE
	$GameOver.show()
	#get_tree().paused = true
	
func update_ui(step):
	match step.step_type:
		QuestManager.INCREMENTAL_STEP:
			var text = "%s %02d/%02d" % [step.details,step.collected,step.required]
			Game.current_level.update_label(text)			
		QuestManager.TIMER_STEP:
			var text = "%s %03d" % [step.details,step.time]
			Game.current_level.update_label(text)
		QuestManager.CALLABLE_STEP:
			print(step)
			QuestManager.progress_quest(step.quest_id,step.id)

func step_updated(step):
	print(step)
	QuestManager.progress_quest(step.quest_id,step.id)
func step_complete(step):
	print(step)
