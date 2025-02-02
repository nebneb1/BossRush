extends Node2D

var damage = 1
const SPEED = 30.0

var timeout = 14.0
var timer = 0.0 

const GHOST_TIME = 0.01
var ghost_timer = 0.0
const GHOST_SCENE = preload("res://Scenes/Ghost.tscn")
@onready var animations: Sprite2D = $AcheBullet

func _ready() -> void:
	damage = int(floor(pow(2, Global.days_survived/5.0)))
	$Area2D.damage = damage
	$Area2D.used = false

func _process(delta: float) -> void:
	timer += delta
	if timer > timeout:
		queue_free()
	$Area2D.used = false
	if is_instance_valid(Global.player):
		position += (Global.player.global_position-global_position - Vector2(0.0, -10.0)).normalized() * SPEED * delta * pow(1.1, Global.days_survived/5.0)
	ghost_timer += delta
	if ghost_timer >= GHOST_TIME:
		var inst = GHOST_SCENE.instantiate()
		inst.position = global_position - Vector2(640, 360)/2.0 + Vector2(1, 0)
		inst.rotation = rotation
		inst.texture = animations.texture
		inst.z_index = z_index -1
		get_parent().add_child(inst)
		ghost_timer -= GHOST_TIME
	
