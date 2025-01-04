extends CharacterBody2D

# movement constants
const SPEED = 75.0
const ACCEL = 30.0
const DAMP = 10.0
const DEADZONE = 0.1

# dash parameters
const DASH_COOLDOWN = 0.15
const DASH_TIME = 0.75
const DASH_INV_TIME = 0.5
const DASH_SPEED_BONUS = 1.5

@onready var dash_animation = $Dash

var dash_cooldown_timer = 0.0
var dash_direction : Vector2 = Vector2.UP
var dashing = false

# parry parameters
const PARRY_WIND_UP = 0.5
const PARRY_DURRATION = 0.15
const PARRY_COOLDOWN = 0.15
const PARRY_COMBO_BONUS = 1.0
const DASH_PARRY_COMBO_BONUS = 2.0

@onready var parry_animation = $Parry

var parry_timer = 0.0
var parry_active = false


# effect vars
var invenerable_timer = 0.0
var invenerable = false

func _physics_process(delta: float) -> void:
	# we get input direction like this becuse it works for both controller and kbm!
	var dir = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), 
	Input.get_action_strength("down") - Input.get_action_strength("up")).normalized() 
	
	if not dashing:
		if dash_cooldown_timer >= 0: dash_cooldown_timer -= delta
		
		if abs(dir.length()) < DEADZONE: 
			velocity = velocity.lerp(Vector2.ZERO, delta * DAMP)
		else:
			velocity = velocity.lerp(dir * SPEED, delta * ACCEL)
			dash_direction = dir 
	else:
		velocity = dash_direction * SPEED * DASH_SPEED_BONUS
	
	if invenerable_timer > 0: invenerable_timer -= delta
	else: invenerable = false
	
	if parry_timer >= 0.0:
		parry_active = parry_timer <= PARRY_DURRATION + PARRY_COOLDOWN and parry_timer > PARRY_COOLDOWN
		parry_timer -= delta
	
	
	modulate.a = 1.0-float(invenerable)*0.5 # temp
	
	
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash") and dash_cooldown_timer <= 0.0:
		dash_cooldown_timer = DASH_COOLDOWN
		invenerable_timer = DASH_INV_TIME
		dashing = true
		invenerable = true
		dash_animation.speed_scale = 1/DASH_TIME
		dash_animation.play("dash")
	
	if event.is_action_pressed("parry") and dash_cooldown_timer <= 0.0 and parry_timer <= 0.0:
		parry_timer = PARRY_WIND_UP + PARRY_DURRATION + PARRY_COOLDOWN
		parry_animation.play("parry_charge")
		parry_animation.speed_scale = 1/PARRY_WIND_UP
		print("Curse you *parry* the platapus! heh")
		
		
		
		


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "parry_charge":
		parry_animation.play("parry")
		parry_animation.speed_scale = 1 / PARRY_DURRATION
	
	if anim_name == "dash":
		dashing = false


func _on_damage_detector_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
