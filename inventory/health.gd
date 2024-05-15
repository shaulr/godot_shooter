class_name HealthItem extends InventoryItem

@export var health_increase: int = 100

func use(player: Player):
	player.heal(health_increase)
