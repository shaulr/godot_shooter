extends Area2D
@export var healing: float = 0
@export var drop_chance: float = 0.2
@export var is_consumable: bool = true
@export var item: Item
@onready var sprite = $Sprite2D

func _ready():
	sprite.texture = item.texture
	scale()
	
func scale():
	var area_size = item.maxTextureSize * 3/4
	var texture_size = item.texture.get_size()
	var sx = area_size.x / texture_size.x
	var sy = area_size.y / texture_size.y
	var sprite_scale_factor = min(sx, sy)
	sprite.scale = Vector2(sprite_scale_factor, sprite_scale_factor)
	
		
func _enter_tree():
	add_to_group("game_events")

func on_save_data(saved_data:Array[SavedData]):
	var data = SavedCollectibleData.new() as SavedCollectibleData
	data.position = global_position
	data.scene_path = scene_file_path
	data.healing = healing
	data.drop_chance = drop_chance
	data.is_consumable = is_consumable
	data.item = item
	saved_data.append(data)
	
func on_pre_load():
	get_parent().remove_child(self)
	queue_free()
	
func on_load(savedData: SavedData):
	if savedData is SavedCollectibleData:
		var data = savedData as SavedCollectibleData
		global_position = data.position
		healing = data.healing
		drop_chance = data.drop_chance
		is_consumable = data.is_consumable
		item = data.item		

func collect(inventory: Inventory):
	inventory.insert(item)
	queue_free()
	
func get_healing():
	return healing

func get_drop_chance():
	return drop_chance
	
func get_is_consumable():
	return is_consumable
