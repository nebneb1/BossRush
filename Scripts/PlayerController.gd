extends CharacterBody2D

const SPEED = 75.0
const ACCEL = 30.0
const DAMP = 10.0
const DEADZONE = 0.1


const DASH_COOLDOWN = 0.15
const DASH_TIME = 0.75
const DASH_INV_TIME = 0.5
const DASH_SPEED_BONUS = 1.5
@onready var animation_player = $Dash

var dash_cooldown_timer = 0.0
var invenerable_timer = 0.0
var dash_direction : Vector2 = Vector2.UP
var dashing = false
var invenerable = false


func _physics_process(delta: float) -> void:
	var dir = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), 
	Input.get_action_strength("down") - Input.get_action_strength("up")).normalized()
	
	if not dashing:
		if dash_cooldown_timer >= 0: dash_cooldown_timer -= delta
		
		if abs(dir.length()) < DEADZONE: 
			velocity = velocity.lerp(Vector2.ZERO, delta * DAMP)
		else:
			velocity = velocity.lerp(dir * SPEED, delta * ACCEL)
			dash_direction = velocity.normalized() 
	else:
		velocity = dash_direction * SPEED * DASH_SPEED_BONUS
	
	if invenerable_timer > 0: invenerable_timer -= delta
	else: invenerable = false
	
	modulate.a = 1.0-float(invenerable)*0.5
	
	
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash") and dash_cooldown_timer <= 0.0:
		dash_cooldown_timer = DASH_COOLDOWN
		invenerable_timer = DASH_INV_TIME
		dashing = true
		invenerable = true
		animation_player.speed_scale = 1/DASH_TIME
		animation_player.play("dash")
		
		
		


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dash":
		dashing = false
