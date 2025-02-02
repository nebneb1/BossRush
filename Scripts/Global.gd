extends Node

const BASE_MAX_COMBO = 8.0
var max_combo = BASE_MAX_COMBO
var combo = 1.0

var prev_points = 0.0
var points : int = 0
var points_gained = 0.0

const BASE_MAX_HEALTH = 50
var max_health = BASE_MAX_HEALTH
var health = BASE_MAX_HEALTH

var curr_boss_health = 0.0
var curr_boss_max_health = 0.0
var player : CharacterBody2D
var boss : Boss
var main : Control
var days_survived : int = 0
var player_hit : AnimationPlayer

const SCENE_SEQUENCE = ["shop", "ache", "anotherday"]
var next_scenes = SCENE_SEQUENCE.duplicate()

const BOSS_HEALTH : Dictionary = {
	"ache" : 10
}

const PRICE_RANGES : Dictionary = {
	"common": [50, 100],
	"rare": [150, 225],
	"legendary": [375, 500]
}
const RELITIVE_PRICE_MAX_DAY = 10.0
const PRICE_RELITIVE : Dictionary = {
	"common": [0.10, 0.20],
	"rare": [0.40, 0.60],
	"legendary": [0.90, 0.95]
}


@onready var avalable_memories : Array

var current_memories = []

var active_hover
func add_memory(memory):
	if typeof(memory) == TYPE_INT:
		current_memories.append(avalable_memories[memory])
	
	elif typeof(memory) == TYPE_STRING:
		for mem in avalable_memories:
			if mem["name"] == memory: 
				current_memories.append(mem)
				break
	else:
		printerr("Invalid memory type: ", typeof(memory))

func remove_memory(memory):
	if typeof(memory) == TYPE_INT:
		for mem in current_memories:
			if mem["name"] == avalable_memories[memory]["name"]:
				current_memories.remove(mem)
				break
	
	elif typeof(memory) == TYPE_STRING:
		for mem in current_memories:
			if mem["name"] == memory:
				current_memories.remove(mem)
				break
	else:
		printerr("Invalid memory type: ", typeof(memory))

func has_memory(memory):
	if typeof(memory) == TYPE_INT:
		for mem in current_memories:
			if mem["name"] == avalable_memories[memory]["name"]:
				return true
		return false
	
	elif typeof(memory) == TYPE_STRING:
		for mem in current_memories:
			if mem["name"] == memory:
				return true
		return false
	else:
		printerr("Invalid memory type: ", typeof(memory))
		
func get_memory(memory):
	if typeof(memory) == TYPE_INT:
		for mem in current_memories:
			if mem["name"] == avalable_memories[memory]["name"]:
				return mem
	
	elif typeof(memory) == TYPE_STRING:
		for mem in current_memories:
			if mem["name"] == memory:
				return mem
	else:
		printerr("Invalid memory type: ", typeof(memory))

func run_memories(channel : String, return_arg = null, args : Array = []):
	for memory in current_memories:
		if memory["channel"].has(channel):
			var combined_args : Array = [channel, memory, return_arg]
			combined_args.append_array(args)
			return_arg = memory["function"].callv(combined_args)
	
	return return_arg

func random_weighted(from : Array, weight_index : int = 1) -> Array:
	var total_chance = 0
	for value in from:
		if typeof(value) == TYPE_ARRAY and value.size() >= weight_index:
			total_chance += value[weight_index]
		else:
			printerr("pick_random_weighted: Improperly formatted array: ", from, "\n\nindex: ", weight_index)
			return []
	
	var random_value = randi_range(1, total_chance)
	var temp = random_value
	for value in from:
		if random_value <= value[weight_index]:
			return value
		else:
			random_value -= value[weight_index]
	
	printerr("pick_random_weighted: couldn't find a solution for : ", from, "\n\nrandom value: ", random_value)
	return []

func random_memory(rarity : String, exclude : Array):
	var pool = []
	for memory in avalable_memories:
		if memory["rarity"] == rarity and not has_memory(memory["name"]) and not exclude.has(memory["name"]):
			pool.append(memory)
	
	if pool.size() == 0:
		for memory in avalable_memories:
			if not has_memory(memory["name"]):
				pool.append(memory)
	
	
	return pool.pick_random()

func random_price(rarity: String):
	print(rarity)
	var absolute_price = randi_range(PRICE_RANGES[rarity][0], PRICE_RANGES[rarity][1])
	print(absolute_price)
	print(absolute_price * floor(pow(1.25, Global.days_survived/5.0)))
	return absolute_price * floor(pow(1.25, Global.days_survived/5.0))

var _first_scene = true
func next_scene():
	if _first_scene:
		_first_scene = false
		if main:
			main.switch_scene(next_scenes[0])
	else:
		if next_scenes.size() <= 0: next_scenes = SCENE_SEQUENCE.duplicate()
		if main:
			main.trans_to_scene(next_scenes[0], "fade_to_black", 3.0)
	
	next_scenes.pop_front()



func _ready() -> void:
	reset_all()
	randomize()

var _prev_combo = 1.0
var _sec_timer = 0.0
const MENU = preload("res://Scenes/Menu.tscn")
const ESC_TIME = 2.0
var esc_timer = 0.0
func _process(delta: float):
	if Input.is_action_pressed("esc"):
		esc_timer += delta
		if esc_timer > ESC_TIME:
			esc_timer = 0
			get_tree().change_scene_to_packed(MENU)
			reset_all()
	else:
		esc_timer = 0
			
	combo = clamp(combo, 1.0, max_combo)
	health = clamp(health, 0.0, max_health)
	
	run_memories("frame", delta)
	
	if combo != _prev_combo:
		run_memories("combo_change")
	
	_prev_combo = combo
	
	_sec_timer += delta
	if _sec_timer >= 1.0:
		_sec_timer -= 1.0
		run_memories("sec_loop")


func reset_all():
	esc_timer = 0.0
	_sec_timer = 0.0
	_prev_combo = 1.0
	_first_scene = true
	active_hover = null
	current_memories = []
	next_scenes = SCENE_SEQUENCE.duplicate()
	max_health = BASE_MAX_HEALTH
	health = BASE_MAX_HEALTH
	curr_boss_health = 0.0
	curr_boss_max_health = 0.0
	player = null
	boss = null
	main = null
	days_survived = 0
	player_hit = null
	max_combo = BASE_MAX_COMBO
	combo = 1.0
	prev_points = 0.0
	points = 0
	points_gained = 0.0
	avalable_memories = [
	#{
		#"name": "Confusion",
		#"description": "Inverts your direction of movement",
		#"icon": preload("res://Art/Sprites/Sparkles/star1.png"),
		#"channel": ["dir"],
		#"rarity": "common",
		#"constants" : {},
		#"function": func (channel : String, memory : Dictionary, move_dir : Vector2): 
			#return -move_dir
			#,
		#"persistant": []
	#},{
		#"name": "Reassurance",
		#"description": "Reduces incoming damage by 1/[combo level]",
		#"icon": preload("res://Art/Sprites/Items/Reassurance.png"),
		#"channel": ["incoming_damage"],
		#"rarity": "rare",
		#"constants" : {},
		#"function": func (channel : String, memory : Dictionary, damage : int):
			#var new_damage : float = damage
			#new_damage = floor(new_damage - new_damage * 1.0 / combo)
			#return int(new_damage)
			#,
		#"persistant": []
	#},
	{
		"name": "Confidence",
		"description": "Every [num_parry] parrys increases your combo by +[bonus]",
		"icon": preload("res://Art/Sprites/Sparkles/star7.png"),
		"channel": ["parry_combo"],
		"rarity": "rare",
		"constants" : {"num_parry" : 3, "bonus": 4},
		"function": func (channel : String, memory : Dictionary, combo_bonus):
			memory["persistant"][0] += 1
			
			if memory["persistant"][0] >= memory["constants"]["num_parry"]:
				memory["persistant"][0] = 0
				combo_bonus += memory["constants"]["bonus"]
			
			return combo_bonus
			,
		"persistant": [0]
	},{
		"name": "Comfort",
		"description": "Bosses now only start with [percent]% of their original health",
		"icon": preload("res://Art/Sprites/Items/Comfort.png"),
		"channel": ["boss_health"],
		"rarity": "common", # common, rare, legendary
		"constants" : {"percent" : 80},
		"function": func (channel : String, memory : Dictionary, health):
			var c = memory["constants"]
			var p = memory["persistant"]
			return health * (c["percent"]/100.0)
			,
		"persistant": []
	},{
		"name": "Focus",
		"description": "Future shop memories are [discount_percent]% off, but there are [removed_percent]% less to choose from",
		"icon": preload("res://Art/Sprites/Items/Focus.png"),
		"channel": ["memory_number", "memory_price"],
		"rarity": "rare", # common, rare, legendary
		"constants" : {"discount_percent": 50, "removed_percent": 50},
		"function": func (channel : String, memory : Dictionary, arg):
			var c = memory["constants"]
			var p = memory["persistant"]
			if channel == "memory_number":
				return int(arg * (c["removed_percent"]/100.0))
			elif channel == "memory_price":
				return int(arg * (c["discount_percent"]/100.0))
			,
		"persistant": []
	},{
		"name": "Mania", # I think its funny how this has an exploit where if you set your system time back you oneshot the boss
		"description": "You do x[bonus_multiplier] damage, every minute that passes you do [string_decrease] as much damage for that fight",
		"icon": preload("res://Art/Sprites/Items/Mania.png"),
		"channel": ["damage_delt_mult", "boss_spawn"],
		"rarity": "legendary", # common, rare, legendary
		"constants" : {"bonus_multiplier" : 3.0, "decrease": 0.5, "string_decrease": "half"},
		"function": func (channel : String, memory : Dictionary, damage_mult = 1.0):
			var c = memory["constants"]
			var p = memory["persistant"]
			if channel == "boss_spawn":
				p[0] = Time.get_unix_time_from_system()
				return damage_mult
			elif channel == "damage_delt_mult":
				var time_diff = Time.get_unix_time_from_system() - p[0]
				return damage_mult * pow(c["decrease"], (time_diff/60.0)) * c["bonus_multiplier"] 
			,
		"persistant": [0.0]
	},{
		"name": "Clarity",
		"description": "Movement speed increased by x[multiplier]",
		"icon": preload("res://Art/Sprites/Items/Clarity.png"),
		"channel": ["movement_mult"],
		"rarity": "rare", # common, rare, legendary
		"constants" : {"multiplier" : 1.5},
		"function": func (channel : String, memory : Dictionary, mult):
			var c = memory["constants"]
			var p = memory["persistant"]
			return mult * c["multiplier"]
			,
		"persistant": []
	},{
		"name": "Self-Respect",
		"description": "Max combo is raised by +[ammount]",
		"icon": preload("res://Art/Sprites/Items/SelfRespect.png"),
		"channel": ["base_max_combo"],
		"rarity": "rare", # common, rare, legendary
		"constants" : {"ammount": 4},
		"function": func (channel : String, memory : Dictionary, curr_combo):
			var c = memory["constants"]
			var p = memory["persistant"]
			return curr_combo + c["ammount"] 
			,
		"persistant": []
	},{
		"name": "Authenticity",
		"description": "You start each fight with max combo, you lose all combo the first time you get hit (per fight)",
		"icon": preload("res://Art/Sprites/Items/Authenticity.png"),
		"channel": ["start_combo", "boss_spawn", "incoming_damage"],
		"rarity": "legendary", # common, rare, legendary
		"constants" : {},
		"function": func (channel : String, memory : Dictionary, start_combo):
			var c = memory["constants"]
			var p = memory["persistant"]
			match channel:
				"start_combo":
					return max_combo
				"boss_spawn":
					p[0] = true
					return max_combo
				"incoming_damage":
					if p[0]:
						combo = 1.0
						p[0] = false
					return max_combo
					
			,
		"persistant": [false]
	},{
		"name": "Consistency",
		"description": "Your attacks reach [mult]x further",
		"icon": preload("res://Art/Sprites/Items/Consistency.png"),
		"channel": ["attack_size"],
		"rarity": "common", # common, rare, legendary
		"constants" : {"mult": 1.5},
		"function": func (channel : String, memory : Dictionary, size):
			var c = memory["constants"]
			var p = memory["persistant"]
			return size * c["mult"]
			,
		"persistant": []
	},{
		"name": "Perfection",
		"description": "If you don't get hit in a fight, multiply your points gained by x[mult]",
		"icon": preload("res://Art/Sprites/Items/Perfection.png"),
		"channel": ["points_gained_end", "incoming_damage"],
		"rarity": "rare", # common, rare, legendary
		"constants" : {"mult": 4.0},
		"function": func (channel : String, memory : Dictionary, points):
			var c = memory["constants"]
			var p = memory["persistant"]
			if channel == "points_gained_end" and p[0]:
				return points * c["mult"]
			elif channel == "incoming_damage":
				p[0] = false
				return points
			else:
				p[0] = true
				return points
			,
		"persistant": [true]
	},{
		"name": "Anger",
		"description": "A successful attack raises your combo by +[increase]",
		"icon": preload("res://Art/Sprites/Items/Anger.png"),
		"channel": ["base_damage"],
		"rarity": "legendary", # common, rare, legendary
		"constants" : {"increase" : 0.25},
		"function": func (channel : String, memory : Dictionary, damage):
			var c = memory["constants"]
			var p = memory["persistant"]
			combo += c["increase"]
			return damage
			,
		"persistant": []
	},{
		"name": "Acceptance",
		"description": "Your successful parries now deal damage equal to your attack to the boss",
		"icon": preload("res://Art/Sprites/Items/Acceptance.png"),
		"channel": ["parry_combo"],
		"rarity": "common", # common, rare, legendary
		"constants" : {},
		"function": func (channel : String, memory : Dictionary, combo):
			var c = memory["constants"]
			var p = memory["persistant"]
			boss.damage(run_memories("base_damage", 1.0) * run_memories("damage_delt_mult", 1.0))
			return combo
			,
		"persistant": []
	},{
		"name": "Allowance",
		"description": "You gain [ammount] points at the end of every fight",
		"icon": preload("res://Art/Sprites/Items/Allowance.png"),
		"channel": ["points_gained_end"],
		"rarity": "common", # common, rare, legendary
		"constants" : {"ammount" : 20},
		"function": func (channel : String, memory : Dictionary, points):
			var c = memory["constants"]
			var p = memory["persistant"]
			return points + c["ammount"]
			,
		"persistant": []
	},{
		"name": "Forethought",
		"description": "Every time you start a fight, your points are multiplied by x[mult]",
		"icon": preload("res://Art/Sprites/Items/Forethought.png"),
		"channel": ["fight_start"],
		"rarity": "rare", # common, rare, legendary
		"constants" : {"mult": 1.2},
		"function": func (channel : String, memory : Dictionary, arg):
			var c = memory["constants"]
			var p = memory["persistant"]
			points *= c["mult"]
			return
			,
		"persistant": []
	},{
		"name": "Amends",
		"description": "Gain +[ammount] health at the start of every fight",
		"icon": preload("res://Art/Sprites/Items/Amends.png"),
		"channel": ["fight_start"],
		"rarity": "rare", # common, rare, legendary
		"constants" : {"ammount" : 1},
		"function": func (channel : String, memory : Dictionary, arg):
			var c = memory["constants"]
			var p = memory["persistant"]
			health += c["ammount"]
			return
			,
		"persistant": []
	},{
		"name": "Medication",
		"description": "After purchasing this item, your attacks perminently gain +x[increase] damage after every fight",
		"icon": preload("res://Art/Sprites/Items/Medication.png"),
		"channel": ["points_gained_end", "damage_delt_mult"],
		"rarity": "rare", # common, rare, legendary
		"constants" : {"increase" : 0.1},
		"function": func (channel : String, memory : Dictionary, arg):
			var c = memory["constants"]
			var p = memory["persistant"]
			if channel == "points_gained_end":
				p[0] += c["increase"]
				return arg
			elif channel == "damage_delt_mult":
				return arg * (p[0])
			
			return arg
			,
		"persistant": [1.0]
	},{
		"name": "Dissociation",
		"description": "Every time you achieve max combo, you are immune the next [times] times you are attacked",
		"icon": preload("res://Art/Sprites/Items/Dissociation.png"),
		"channel": ["combo_change"],
		"rarity": "rare", # common, rare, legendary
		"constants" : {"times": 2},
		"function": func (channel : String, memory : Dictionary, arg):
			var c = memory["constants"]
			var p = memory["persistant"]
			if combo >= max_combo - 0.001:
				player.immunity += c["times"]
			return
			,
		"persistant": []
	},{
		"name": "Sensitivity",
		"description": "Next time you die, instead revive to [percent]% health",
		"icon": preload("res://Art/Sprites/Items/Sensitivity.png"),
		"channel": [""],
		"rarity": "legendary", # common, rare, legendary
		"constants" : {"percent" : 50},
		"function": null, # handled in player controller
		"persistant": [true]
	},{
		"name": "Abstraction",
		"description": "Start each fight with +[start_points] points, every second in battle, lose -[point_loss] points, you no longer gain points from attacks.",
		"icon": preload("res://Art/Sprites/Items/Abstraction.png"),
		"channel": ["sec_loop", "fight_start", "fight_end", "point_multiplier"],
		"rarity": "rare", # common, rare, legendary
		"constants" : {"start_points" : 1200, "point_loss": 10},
		"function": func (channel : String, memory : Dictionary, arg):
			var c = memory["constants"]
			var p = memory["persistant"]
			match channel:
				"sec_loop":
					if p[0] and points_gained >= c["point_loss"]:
						points_gained -= c["point_loss"]
				"fight_start":
					p[0] = true
					points_gained = c["start_points"]
				"fight_end":
					p[0] = false
				
			return 0.0
			,
		"persistant": [false]
	},{
		"name": "Transference",
		"description": "Every time you are hit, gain +x[bonus] attack that battle",
		"icon": preload("res://Art/Sprites/Items/Transference.png"),
		"channel": ["incoming_damage", "fight_start", "damage_delt_mult"],
		"rarity": "rare", # common, rare, legendary
		"constants" : {"bonus" : 0.5},
		"function": func (channel : String, memory : Dictionary, damage):
			var c = memory["constants"]
			var p = memory["persistant"]
			match channel:
				"incoming_damage":
					p[0] += c["bonus"]
					return damage
					
				"damage_delt_mult":
					return damage * p[0]
					
				"fight_start":
					p[0] = 1.0
			return
			,
		"persistant": [1.0]
	},{
		"name": "Cognition",
		"description": "Attacking while dashing deals an additional x[mult] damage",
		"icon": preload("res://Art/Sprites/Items/Cognition.png"),
		"channel": ["damage_delt_mult"],
		"rarity": "common", # common, rare, legendary
		"constants" : {"mult" : 2.0},
		"function": func (channel : String, memory : Dictionary, multiplier):
			var c = memory["constants"]
			var p = memory["persistant"]
			if player.dash_cooldown_timer >= 0.001:
				return multiplier * c["mult"]
			
			return multiplier
			,
		"persistant": []
	},{
		"name": "Meditation",
		"description": "Increase your combo by +[bonus] for every [seconds] seconds you don't press any inputs, if you are hit, lose any combo gained",
		"icon": preload("res://Art/Sprites/Items/Meditation.png"),
		"channel": ["frame", "fight_start", "fight_end", "incoming_damage"],
		"rarity": "common", # common, rare, legendary
		"constants" : {"bonus" : 1.0, "seconds" : 2.0},
		"function": func (channel : String, memory : Dictionary, delta):
			var c = memory["constants"]
			var p = memory["persistant"]
			match channel:
				"fight_start":
					p[0] = true
					p[2] = 0.0
					p[1] = 0.0
				"fight_end":
					p[0] = false
				"frame":
					if p[0]:
						if not Input.is_anything_pressed():
							p[1] += delta
							if p[1] >= c["seconds"]:
								combo += c["bonus"]
								p[2] += c["bonus"]
								p[1] -= c["seconds"]
						else:
							p[1] = 0.0
				"incoming_damage":
					
					combo = clamp(combo - p[2], 1.0,  max_combo)
			return delta
			,
		"persistant": [false, 0.0, 0.0]
	}
	#,{
		#"name": "Final",
		#"description": "Attacking immediately after dashing deals an additional x[mult] damage",
		#"icon": preload("res://Art/Sprites/Sparkles/star8.png"),
		#"channel": ["damage_delt_mult"],
		#"rarity": "common", # common, rare, legendary
		#"constants" : {"mult" : 2.0},
		#"function": func (channel : String, memory : Dictionary, multiplier):
			#var c = memory["constants"]
			#var p = memory["persistant"]
			#if player.dash_cooldown_timer >= 0.001:
				#return multiplier * c["mult"]
			#
			#return multiplier
			#,
		#"persistant": []
	#}
]
