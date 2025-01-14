extends Node2D
var health = Global.BOSS_HEALTH["ache"]

func _on_damage_area_entered(area: Area2D) -> void:
	if area.is_in_group("attack") and not area.used:
		health -= area.damage
		area.used = true
		$DamageSound.play()
		if health <= 0:
			queue_free()
