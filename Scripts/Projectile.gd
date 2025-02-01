extends Node2D

const TIMEOUT = 10.0
var speed = 150.0
var timer = 0.0
var damage = 1

const GHOST_TIME = 0.05
var ghost_timer = 0.0
const GHOST_SCENE = preload("res://Scenes/Ghost.tscn")
@onready var animations: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	$Area2D.damage = damage

func _process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	timer += delta
	if timer > TIMEOUT:
		queue_free()
	
	ghost_timer += delta
	if ghost_timer >= GHOST_TIME:
		var inst = GHOST_SCENE.instantiate()
		inst.position = global_position - Vector2(640, 360)/2.0
		inst.rotation = rotation
		inst.scale = animations.scale
		inst.texture = animations.sprite_frames.get_frame_texture(animations.animation, animations.frame)
		inst.z_index = z_index -1
		get_parent().add_child(inst)
		ghost_timer -= GHOST_TIME
	
