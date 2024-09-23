class_name Item
extends Resource

@export var name: String
@export var texture: Texture2D
@export var maxTextureSize: Vector2
@export var drop_weight: float
@export var scene_path: String

func use(player: Player):
	var result : Collectible = null
	if ResourceLoader.exists(scene_path) :
		result = ResourceLoader.load(scene_path).instantiate()
		if result:
			if result.is_equipable:
				player.equip(result)
			elif result.is_consumable:
				player.heal(result.get_healing())
		else:
			print("error loading scene ", scene_path)
	else:
		print("scene does not exist ", scene_path)

