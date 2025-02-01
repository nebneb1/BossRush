extends Boss

const IDLE_TIME = [1.5, 2.0]
const SURROUND_ATTACK_TIME = [10.0, 15.0]
const ATTACKS = [State.WOMP, State.SURROUND, State.SWEEP]
const ATTACKS_SWEEP = [State.SURROUND, State.WOMP, State.SWEEP, State.SWEEP, State.SWEEP, State.SWEEP]
const PROJECTILE_PATTERNS = ["sweep", "impassible"]
const GHOST_TIME = 0.1

enum State {
	IDLE,
	SURROUND,
	SURROUND_IDLE,
	SURROUND_BACK,
	SWEEP,
	WOMP
}



@export var sprite : AnimatedSprite2D
@export var particle_parent : Node
@export_range(2, 20) var epsilon = 5
@export var projectile_holder : Node2D 

@onready var ghost_scene = preload("res://Scenes/Ghost.tscn")
@onready var particle_scene = preload("res://Scenes/boss1particles2.tscn")
@onready var animated_sprites = [$Sprite/AnimatedSprite2D, $Sprite/AnimatedSprite2D2]
@onready var projectile = preload("res://Scenes/Boss1Proj.tscn")
@onready var damage_areas: Node2D = $DamageAreas

signal state_change()

var current_state : State = State.IDLE
var previous_state : State = State.IDLE
var ghost_timer = 0.0
var left : bool


func _ready() -> void:
	boss_name = "ache"
	Global.run_memories("boss_spawn")
	Global.max_combo = Global.run_memories("base_max_combo", Global.BASE_MAX_COMBO)
	Global.combo = Global.run_memories("start_combo", 1.0)
	Global.boss = self
	Global.run_memories("fight_start")
	set_health()
	
	randomize()
	set_state(State.IDLE)
	

func spawn_projectile(pos : Vector2, rot : float, speed : float = 150.0, damage : int = 1):
	var inst = projectile.instantiate()
	inst.position = pos
	inst.rotation = rot
	inst.damage = damage
	inst.speed = speed
	projectile_holder.add_child(inst)

func proj_sweep(SOURCE_POS : Array, AMMOUNT : int = 10, ANGLE_SPREAD : float = PI/2.0, PROJ_SPACING : float = 0.01, speed = 150.0):
	const STOP_TIME = 0.2
	
	for pos in SOURCE_POS:
		for i in range(AMMOUNT):
			var prog = (float(i) / float(AMMOUNT))
			spawn_projectile(pos[0], pos[1] + prog * ANGLE_SPREAD - ANGLE_SPREAD/2.0, speed)
			await get_tree().create_timer(PROJ_SPACING).timeout
		
		await get_tree().create_timer(STOP_TIME).timeout

func proj_grid(SOURCE_POS : Array):
	const AMMOUNT = 5
	const TIMES = 5
	const STOP_TIME = 2.0
	const SPEED = 75.0
	const OFFSET = 30
	for i in range(TIMES):
		for pos in SOURCE_POS:
			for j in range(AMMOUNT):
				spawn_projectile((pos[1]-pos[0])*float(j)/float(AMMOUNT) + pos[0], pos[2], SPEED)
		
		await get_tree().create_timer(STOP_TIME).timeout


func random_val(between : Array):
	return randf_range(between[0], between[1])

func set_state(to : State):
	previous_state = current_state
	current_state = to
	match current_state:
		State.IDLE:
			play_animation("Idle")
			await get_tree().create_timer(random_val(IDLE_TIME) - 1.0).timeout
			var attack
			if previous_state == State.SWEEP:
				attack = ATTACKS_SWEEP.pick_random()
			else:
				attack = ATTACKS.pick_random()
				
			if attack == State.SWEEP: left = bool(randi_range(0, 1))
			match attack:
				State.SURROUND:
					$Tele.play()
					$Warning.play("Surround")
				
				State.SWEEP:
					$Tele.play()
					if left:
						$Warning.play("SweepL")
					else:
						$Warning.play("SweepR")
				
				State.WOMP:
					$Tele.play()
					$Warning.play("Womp")
					play_animation("Womp")
				
					
					
			await get_tree().create_timer(1.0).timeout
			set_state(attack) # TODO : Change to pick random attack that wasnt the last one used
		
		State.SURROUND:
			$woosh.stop()
			$woosh.play("woosh")
			var inst = BOSS_1_PROJ_2.instantiate()
			projectile_holder.add_child(inst)
			play_animation("Surround")
		
		State.SURROUND_IDLE:
			play_animation("SurroundIdle")
			surround()
			
			await get_tree().create_timer(random_val(SURROUND_ATTACK_TIME)).timeout
			set_state(State.SURROUND_BACK)
		
		State.SURROUND_BACK:
			$Warning.play("Idle")
			$woosh.stop()
			$woosh.play("woosh")
			play_animation("SurroundBack")
		
		State.SWEEP:
			
			$woosh.stop()
			$woosh.play("woosh")
			if left:
				play_animation("SweepL")
				await get_tree().create_timer(0.5).timeout
				damage_areas.get_node("SweepL").set_used(false)
				damage_areas.get_node("SweepL").time = 0.1
			else: 
				play_animation("SweepR")
				await get_tree().create_timer(0.5).timeout
				damage_areas.get_node("SweepR").set_used(false)
				damage_areas.get_node("SweepR").time = 0.1
			$Warning.play("Idle")
		
		State.WOMP:
			$woosh.stop()
			$woosh.play("woosh")
			$Warning.play("Idle")
			

func play_animation(anim : String, speed_scale : float = 1.0):
	animated_sprites[0].play(anim, speed_scale)
	animated_sprites[1].play(anim, speed_scale)

func _on_animation_finished() -> void:
	match current_state:
		State.SURROUND:
			set_state(State.SURROUND_IDLE)
		State.SURROUND_BACK:
			set_state(State.IDLE)
		State.SWEEP:
			set_state(State.IDLE)
		State.WOMP:
			set_state(State.IDLE)
			
const SURROUND_INTENSITY = 4.0
const BOSS_1_PROJ_2 = preload("res://Scenes/Boss1Proj2.tscn")
func surround():
	const OFFSET = 30
	proj_grid([
		[Vector2(-250, -150), Vector2(250, -150), PI/2.0], [Vector2(-250+OFFSET, -150-OFFSET), Vector2(250+OFFSET, -150-OFFSET), PI/2.0],
		[Vector2(-280, -175), Vector2(-280, 150), 0.0], [Vector2(280, -175+OFFSET), Vector2(280, 150+OFFSET), PI]
	])
	for i in range(2):
		await get_tree().create_timer(SURROUND_INTENSITY).timeout
		match ["sweep", "impassible", "corners"].pick_random():
			"sweep": proj_sweep([[Vector2(-280.0,25.0), 0.0], [Vector2(280.0, 25.0), PI], [Vector2(-280.0, 25.0), 0.0 - 0.2], [Vector2(280.0, 25.0), PI - 0.2]])
			"impassible": proj_sweep([[Vector2(0.0, -160.0), PI/2.0]], 50, PI*0.75, 0.03, 100.0)
			"corners": proj_sweep([[Vector2(240, -150), PI*0.75], [Vector2(240, -150)*1.1, PI*0.75], [Vector2(240, -150)*1.2, PI*0.75], [Vector2(-240, -150), PI*0.25], [Vector2(-240, -150)*1.1, PI*0.25], [Vector2(-240, -150)*1.2, PI*0.25]], 3, PI/4, 0.05, 125.0)


func _process(delta: float) -> void:
	ghost_timer += delta
	if ghost_timer >= GHOST_TIME:
		var inst = ghost_scene.instantiate()
		inst.z_index = z_index - 1
		inst.global_position = global_position
		inst.texture = animated_sprites[0].sprite_frames.get_frame_texture(animated_sprites[0].animation, animated_sprites[0].frame)
		get_parent().add_child(inst)
		ghost_timer -= GHOST_TIME
	
	match current_state:
		State.SURROUND_IDLE:
			
			pass
			
			



func update_particles():
	var texture : Texture2D
	texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
		
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(texture.get_image())
	
	var polys = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, texture.get_size()), epsilon)
	#for child in particle_parent.get_children():
		#child.free()
	

	for poly in polys:
		for point in poly:
			var inst = particle_scene.instantiate()
			inst.position  = point
			particle_parent.add_child(inst)
		#var collision_polygon := CollisionPolygon2D.new()
		#collision_polygon.polygon = poly
		#collision_polygon.position -= Vector2(bitmap.get_size()/2)
		#add_child(collision_polygon)
	





