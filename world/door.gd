class_name Door extends Area2D
@onready var game = $"/root/Game"
@export var scene_to_load: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Player:
		scene_manager.change_scene(get_owner(), scene_to_load)

