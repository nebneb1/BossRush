extends Node2D

const TIMEOUT = 10.0
var speed = 150.0
var timer = 0.0
var damage = 1

func _ready() -> void:
	$Area2D.damage = damage

func _process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	timer += delta
	if timer > TIMEOUT:
		queue_free()
	
