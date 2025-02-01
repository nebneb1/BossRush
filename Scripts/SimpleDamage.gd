extends Area2D

@export var damage : int = 1
@export var used = false

var timer : float = 0.0
var time : float = -1.0

func _process(delta: float) -> void:
	if not used and time > 0:
		timer += delta
		if timer > time:
			used = true
			timer = -1
			time = 0

func set_used(val : bool):
	used = val
	if used == false:
		timer = 0.0
		for area in get_overlapping_areas():
			if area.is_in_group("player"):
				Global.player.area_damage(self)
				used = true
		
		
