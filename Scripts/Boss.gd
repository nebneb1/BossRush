extends Node2D
class_name Boss

var health = 1.0
var boss_name = "ache"
var dead = false

func _ready() -> void:
	pass
	#Engine.time_scale = 1 + Global.days_survived / 20.0


	
func set_health():
	health = Global.run_memories("boss_health", Global.BOSS_HEALTH[boss_name]) * pow(2, Global.days_survived / 2.0)
	Global.curr_boss_max_health = health

func _on_damage_area_entered(area: Area2D) -> void:
	if area.is_in_group("attack") and not area.used:
		damage(area.damage)
		area.used = true

func damage(ammount):
	var dmg = clamp(Global.run_memories("base_damage", 1.0) * Global.run_memories("damage_delt_mult", 1.0) * Global.combo * (float(Global.player.dashing) + 1.0), 0.0, Global.boss.health)
	health -= dmg
	if Global.player.dashing:
		Global.player.get_node("Cool").play()
	Global.curr_boss_health = health
	Global.points_gained += clamp(dmg/2.0, 1.0, Global.max_combo) * ammount * Global.combo * Global.run_memories("point_multiplier", 1.0)
	$DamageSound.play()
	$Sprite/Hit.play("hit")
	if health <= 0:
		dead = true
		
		
