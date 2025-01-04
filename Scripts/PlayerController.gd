extends CharacterBody2D

const SPEED = 75.0
const ACCEL = 30.0
const DAMP = 10.0
const DEADZONE = 0.1


func _physics_process(delta: float) -> void:
	var dir = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), 
	Input.get_action_strength("down") - Input.get_action_strength("up")).normalized()
	
	if abs(dir.length()) < DEADZONE: velocity = velocity.lerp(Vector2.ZERO, delta * DAMP)
	else: velocity = velocity.lerp(dir * SPEED, delta * ACCEL)
	
	move_and_slide()

