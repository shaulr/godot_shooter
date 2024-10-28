extends Area2D
@onready var stabPlayer = $stabPlayer
var lastDirection = "down"
var damage = 50
func stab(direction: String):
	lastDirection = direction
	stabPlayer.play("stab" + direction)
	
func get_direction() -> String:
	return lastDirection
	
func get_damage() -> int:
	return damage


func _on_area_2d_body_entered(body):
	if !visible: return
	if body.has_method("get_direction") and body.has_method("get_damage"):
		var body_dir = body.get_direction()
		if body_dir == lastDirection:
			body.take_damage(-1) #backstab instakill
		else:
			body.take_damage(get_damage())
