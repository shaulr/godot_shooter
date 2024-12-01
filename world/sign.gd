@tool
class_name Sign extends Area2D
enum SignType{crossroads, left, right, info}
@export var type: SignType:
	set(new_type):
		type = new_type
		_on_type_set(type)
	
@export_multiline var sign_text: String
@onready var sprite = $Sprite2D

func _ready() -> void:
	_on_type_set(type)

		
func _on_type_set(new_type: int):
	var path = "res://art/signs/signpost_" + SignType.keys()[type] + ".png"
	print_debug("sign sprite path: " + path)
	if !sprite:
		sprite = Sprite2D.new()
		add_child(sprite)
	sprite.texture = load(path)
	sprite.texture_filter = TEXTURE_FILTER_NEAREST

	

func _on_body_entered(body: Node2D) -> void:
	if body == Game.get_player():
		Game.current_level.level_gui.set_label_text(sign_text)

		
func _on_body_exited(body: Node2D) -> void:
	if body == Game.get_player():
		Game.current_level.level_gui.set_label_text("")
