extends Node2D
class_name Boss

var health = 1.0
var boss_name = "ache"

func _ready() -> void:
	pass

func set_health():
	health = Global.run_memories("boss_health", Global.BOSS_HEALTH[boss_name])

func _on_damage_area_entered(area: Area2D) -> void:
	if area.is_in_group("attack") and not area.used:
		damage(area.damage)
		area.used = true

func damage(ammount):
	health -= ammount
	Global.points_gained += ammount * Global.combo
	$DamageSound.play()
	$Sprite/Hit.play("hit", 1.75)
	if health <= 0:
		Global.run_memories("fight_end")
		Global.points += Global.run_memories("points_gained_end", Global.points_gained)
		
		queue_free()
