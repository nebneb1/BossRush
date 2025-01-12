extends CharacterBody2D

# audio
const FOOTSTEP_TIME = 0.3
@export var footstep_player : AudioStreamPlayer


var footstep_timer = 0.0

# anims
@onready var animations = $Sprite
var save_dir = ""

# stats
var health : int = 10
#var iinvenerability_

# movement vars
const SPEED = 75.0
const ACCEL = 30.0
const DAMP = 10.0
const DEADZONE = 0.1

@onready var ghost_scene = preload("res://Scenes/Ghost.tscn")

var movement_disabled : bool = false
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
var parry_sucessful = true

# effect vars
var invenerable_timer = 0.0
var invenerable = false

func _ready() -> void:
	#Global.add_memory(0)
	movement_disabled = true
	#$Fall.play()
	$ParryCharge.pitch_scale = 0.5/(PARRY_WIND_UP+PARRY_DURRATION)
	Global.player = self

var ghost_timer = 0.0
const GHOST_TIME = 0.01

func set_anim(_dir: Vector2):
	if Input.is_action_pressed("left"): save_dir = "left"
	elif Input.is_action_pressed("right"): save_dir = "right"
	elif Input.is_action_pressed("up"): save_dir = "back"
	elif Input.is_action_pressed("down"): save_dir = "front"
	var activate_sprite : String = save_dir
	if _dir.length() > DEADZONE: activate_sprite += "walk"
	if activate_sprite != "":
		animations.play(activate_sprite)

func _physics_process(delta: float) -> void:
	# we get input direction like this becuse it works for both controller and kbm!
	var dir = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), 
	Input.get_action_strength("down") - Input.get_action_strength("up")).normalized() 
	dir = Global.run_memories("dir", dir)
	
	if movement_disabled: 
		dir = Vector2.ZERO
		
	elif not dashing: set_anim(dir)
	
	if abs(dir.length()) > DEADZONE or dashing:
		ghost_timer += delta
		if ghost_timer >= GHOST_TIME:
			var inst = ghost_scene.instantiate()
			inst.global_position = global_position
			inst.texture = animations.sprite_frames.get_frame_texture(animations.animation, animations.frame)
			get_parent().add_child(inst)
			ghost_timer -= GHOST_TIME
	
	if abs(dir.length()) > DEADZONE:
		footstep_timer += delta
		if footstep_timer >= FOOTSTEP_TIME:
			footstep_timer -= FOOTSTEP_TIME
			footstep_player.play()
	
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
		$DashSound.play()
		dash_animation.play("dash")

	if event.is_action_pressed("parry") and dash_cooldown_timer <= 0.0 and parry_timer <= 0.0:
		$ParryCharge.play()
		parry_timer = PARRY_WIND_UP + PARRY_DURRATION + PARRY_COOLDOWN
		parry_animation.play("parry_charge")
		parry_animation.speed_scale = 1/PARRY_WIND_UP
		print("Curse you *parry* the platapus! heh")
	
	if event.is_action_pressed("interact"):
		$Fall.play("Down")
		movement_disabled = true
		$Sprite/Particles.emitting = true
		Global.next_scene()
	
	
	

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "parry_charge":
		parry_animation.play("parry")
		parry_animation.speed_scale = 1 / PARRY_DURRATION
	
	if anim_name == "dash":
		dashing = false



func _on_damage_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("parry") and parry_active:
		parry_sucessful = true
		if dashing or dash_cooldown_timer >= 0.001:
			Global.combo += Global.run_memories("parry_combo", DASH_PARRY_COMBO_BONUS)
		else:
			Global.combo += Global.run_memories("parry_combo", PARRY_COMBO_BONUS)
	
	elif area.is_in_group("damage"):
		damage(Global.run_memories("damage", area.damage))

func damage(ammount : int):
	
	health -= ammount

func _on_fall_animation_finished(anim_name: StringName) -> void:
	movement_disabled = false
	$Sprite/Particles.emitting = false


func _on_parry_charge_finished() -> void:
	if parry_sucessful:
		$ParrySuccess.play()
		parry_sucessful = false
	else:
		$ParryFail.play()
