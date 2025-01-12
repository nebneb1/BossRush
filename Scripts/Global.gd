extends Node

const MAX_COMBO = 8.0
var combo = 1.0
var score : int = 10000
var player : CharacterBody2D
var main : Control

const SCENE_SEQUENCE = ["ache","shop"]
var next_scenes = SCENE_SEQUENCE.duplicate()

const PRICE_RANGES : Dictionary = {
	"common": [50, 100],
	"rare": [150, 225],
	"legendary": [375, 500]
}

@onready var avalable_memories = [
	{
		"name": "Confusion",
		"description": "Inverts your direction of movement",
		"icon": preload("res://Art/Sprites/Sparkles/star1.png"),
		"channel": ["dir"],
		"rarity": "common",
		"function": func testmem1(channel : String, memory : Dictionary, move_dir : Vector2): 
			return -move_dir
			,
		"persistant": []
	},{
		"name": "Reassurance",
		"description": "Reduces incoming damage by 1/[your combo level] (round down)",
		"icon": preload("res://Art/Sprites/Sparkles/star8.png"),
		"channel": ["damage"],
		"rarity": "rare",
		"function": func testmem2(channel : String, memory : Dictionary, damage : int):
			var new_damage : float = damage
			new_damage = floor(new_damage - new_damage * 1.0 / combo)
			return int(new_damage)
			,
		"persistant": []
	},{
		"name": "Confidence",
		"description": "Every 3rd parry increases your combo by +4",
		"icon": preload("res://Art/Sprites/Sparkles/star7.png"),
		"channel": ["parry_combo"],
		"rarity": "legendary",
		"function": func testmem3(channel : String, memory : Dictionary, combo_bonus):
			const NUM_PARRY = 3
			const BONUS = 4
			
			memory["persistant"][0] += 1
			
			if memory["persistant"][0] >= NUM_PARRY:
				memory["persistant"][0] = 0
				combo_bonus += 4
			
			return combo_bonus
			,
		"persistant": [0]
	}
]

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

func run_memories(channel : String, return_arg, args : Array = []):
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

func random_memory(rarity : String):
	var pool = []
	for memory in avalable_memories:
		if memory["rarity"] == rarity and not current_memories.has(memory):
			pool.append(memory)
	
	return pool.pick_random()

func random_price(rarity: String):
	return randi_range(PRICE_RANGES[rarity][0], PRICE_RANGES[rarity][1])

var _first_scene = true
func next_scene():
	if _first_scene:
		_first_scene = false
		main.switch_scene(next_scenes[0])
	else:
		if next_scenes.size() <= 0: next_scenes = SCENE_SEQUENCE.duplicate()
		main.trans_to_scene(next_scenes[0], "fade_to_black", 3.0)
	
	next_scenes.pop_front()



func _ready() -> void:
	randomize()
	call_deferred("next_scene")

func _process(delta: float):
	combo = clamp(combo, 1.0, MAX_COMBO)



