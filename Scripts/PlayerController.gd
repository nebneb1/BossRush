extends CharacterBody2D

# audio
const FOOTSTEP_TIME = 0.3
@export var footstep_player : AudioStreamPlayer


var footstep_timer = 0.0

# anims
@onready var animations = $Sprite
var save_dir = ""

# stats
var damaged_invenerability_time : = 1.5

# movement vars
const SPEED = 75.0
const ACCEL = 30.0
const DAMP = 10.0
const DEADZONE = 0.1

@onready var ghost_scene = preload("res://Scenes/Ghost.tscn")

var movement_disabled : bool = false

# attack parameters
const ATTACK_COOLDOWN = 0.5
const  ATTACK_TIME = 0.1
const ATTACK_MOUSE_DIST = 7.0

@onready var attack_area = $Attack
@onready var attack_anim: AnimatedSprite2D = $Attack/AttackAnim
@onready var attack_anim_player: AnimationPlayer = $AttackAnimPlayer
@onready var damage_detector: Area2D = $DamageDetector

var attack_damage = 1
var attack_disabled : bool = false
var attack_dir : Vector2 = Vector2.RIGHT
var attack_timer = 0.0

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
const PARRY_DURRATION = 0.25
const PARRY_COOLDOWN = 0.15
const PARRY_COMBO_BONUS = 1.0
const DASH_PARRY_COMBO_BONUS = 2.0

@onready var parry_animation = $Parry

var parry_timer = 0.0
var parry_active = false
var parry_sucessful = false

# effect vars
var invenerable_timer = 0.0
var invenerable = false
var immunity : int = 0

func _ready() -> void:
	#Global.add_memory(0)
	movement_disabled = true
	#$Fall.play()
	$ParryCharge.pitch_scale = 0.5/(PARRY_WIND_UP+PARRY_DURRATION)
	attack_area.used = true
	Global.player = self

var ghost_timer = 0.0
const GHOST_TIME = 0.1

func set_anim(_dir: Vector2):
	#if (attack_timer < 0 or attack_disabled) and not dashing:
	if attack_timer > 0.0 and can_attack_anim:
		animations.play("attack")
		can_attack_anim = false
	elif attack_timer <= 0.0:
		can_attack_anim = true
		animations.scale.x = 1.0
		if Input.is_action_pressed("left"): save_dir = "left"
		elif Input.is_action_pressed("right"): save_dir = "right"
		elif Input.is_action_pressed("up"): save_dir = "back"
		elif Input.is_action_pressed("down"): save_dir = "front"
		var activate_sprite : String = save_dir
		if _dir.length() > DEADZONE: activate_sprite += "walk"
		if activate_sprite != "":
			animations.play(activate_sprite)
		if attack_timer > 0.0 and can_attack_anim:
			animations.play("attack")
			can_attack_anim = false
		elif attack_timer <= 0.0:
			can_attack_anim = true

var can_attack_anim = false
func _physics_process(delta: float) -> void:
	# we get input direction like this becuse it works for both controller and kbm!
	var dir = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), 
	Input.get_action_strength("down") - Input.get_action_strength("up")).normalized() 
	dir = Global.run_memories("dir", dir)
	
	attack_area.damage = attack_damage
	
	if not attack_disabled and is_window_in_focus:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		var mouse_direction = get_global_mouse_position() - get_viewport().size/2.0
		if mouse_direction.length() > DEADZONE:
			pass
			#attack_dir = mouse_direction
			
		
		if mouse_direction.length() > ATTACK_MOUSE_DIST:
			pass
			#Input.warp_mouse(get_window().size/2.0 + mouse_direction.normalized() * ATTACK_MOUSE_DIST * 3.0)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if attack_timer > 0.0:
		attack_timer -= delta
		if attack_timer < ATTACK_COOLDOWN - ATTACK_TIME:
			attack_area.used = true
		
	
	
	if movement_disabled: 
		dir = Vector2.ZERO
		
	elif not dashing: set_anim(dir)
	
	if abs(dir.length()) > DEADZONE or dashing:
		ghost_timer += delta
		if ghost_timer >= GHOST_TIME:
			var inst = ghost_scene.instantiate()
			inst.global_position = global_position
			inst.color = inst.color * 2.0
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
			velocity = velocity.lerp(dir * SPEED * Global.run_memories("movement_mult", 1.0), delta * ACCEL)
			dash_direction = dir 
	else:
		velocity = dash_direction * SPEED * DASH_SPEED_BONUS * Global.run_memories("movement_mult", 1.0)
	
	if invenerable_timer > 0:
		invenerable_timer -= delta
	else: 
		$Damage.stop()
		invenerable = false
	
	if parry_timer >= 0.0:
		parry_active = parry_timer <= PARRY_DURRATION + PARRY_COOLDOWN and parry_timer > PARRY_COOLDOWN
		if parry_active and not prev_parry_active:
			$ParrySprite.play("parry")
		parry_timer -= delta
	
	prev_parry_active = parry_active
	
	modulate.a = 1.0-float(invenerable)*0.5 # temp
	
	
	move_and_slide()

var prev_parry_active = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash") and dash_cooldown_timer <= 0.0 and not movement_disabled:
		dash_cooldown_timer = DASH_COOLDOWN
		invenerable_timer = DASH_INV_TIME
		dashing = true
		invenerable = true
		dash_animation.speed_scale = 1/DASH_TIME
		$DashSound.play()
		dash_animation.play("dash")
		animations.stop()
		if save_dir == "right":
			animations.scale.x = -1
		animations.play("roll")
		

	if event.is_action_pressed("parry") and dash_cooldown_timer <= 0.0 and parry_timer <= 0.0:
		$ParryCharge.play()
		
		parry_timer = PARRY_WIND_UP + PARRY_DURRATION + PARRY_COOLDOWN
		parry_animation.play("parry_charge")
		parry_animation.speed_scale = 1/PARRY_WIND_UP
		print("Curse you *parry* the platapus! heh")
	
	if event.is_action_pressed("interact") and attack_disabled:
		next_scene()
	
	if event.is_action_pressed("attack") and attack_timer <= 0 and not attack_disabled and not parry_timer > 0:
		if event.is_action_pressed("attack_up"): attack_dir = Vector2.UP
		elif event.is_action_pressed("attack_down"): attack_dir = Vector2.DOWN
		elif event.is_action_pressed("attack_left"): attack_dir = Vector2.LEFT
		elif event.is_action_pressed("attack_right"): attack_dir = Vector2.RIGHT
		$Swing.play()
		attack_anim.play("attack")
		attack_anim.frame = 0
		attack_anim_player.stop()
		attack_anim_player.play("attack")
		attack_area.damage = 1
		attack_area.scale = Vector2.ONE * Global.run_memories("attack_size", 1.0)
		attack_area.used = false
		attack_timer = ATTACK_COOLDOWN
		attack_area.rotation = attack_dir.angle()

func next_scene():
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
	if area.is_in_group("damage") and not area.used:
		area_damage(area)

func area_damage(area : Area2D):
	print("owie")
	if area.is_in_group("parry") and parry_active:
		invenerable_timer = parry_timer
		parry_sucessful = true
		UI.play_combo_up()
		$ParrySprite/hit.play("hit")
		if dashing or dash_cooldown_timer >= 0.001:
			Global.combo += Global.run_memories("parry_combo", DASH_PARRY_COMBO_BONUS) * (float(dashing) + 1.0)
			$Cool.play()
		else:
			Global.combo += Global.run_memories("parry_combo", PARRY_COMBO_BONUS)* (float(dashing) + 1.0)
	
	elif area.is_in_group("damage") and not invenerable:
		damage(area.damage)

func damage(ammount : int):
	#return
	if is_instance_valid(Global.player_hit):
		Global.player_hit.play("PlayerHit")
	UI.play_health_hit()
	invenerable_timer = damaged_invenerability_time
	invenerable = true
	if immunity <= 0:
		$Damage.play("damage")
		$DamageSound.play()
		Global.health -= Global.run_memories("incoming_damage", ammount)
		if Global.health <= 0.001:
			if Global.has_memory("Sensitivity") and Global.get_memory("Sensitivity")["persistant"][0]:
				Global.get_memory("Sensitivity")["persistant"][0] = false
				Global.health = Global.max_health * Global.get_memory("Sensitivity")["constants"]["percent"]/100.0
			else:
				death()
	else:
		immunity -= 1

func death():
	Global.main.fake_trans_to_scene(Global.main.switch_to_death_screen, "fade_to_black", 5.0)
	queue_free()


func _on_fall_animation_finished(anim_name: StringName) -> void:
	movement_disabled = false
	$Sprite/Particles.emitting = false


func _on_parry_charge_finished() -> void:
	if parry_sucessful:
		$ParrySuccess.play()
		parry_sucessful = false
	else:
		$ParryFail.play()

var is_window_in_focus = true
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			is_window_in_focus = false
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			is_window_in_focus = true
