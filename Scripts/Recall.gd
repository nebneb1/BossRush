extends Node2D

const OFFER_RANGE = [6, 10]
const SPREAD_DISATANCE = 100.0
const WAIT = 0.1

@onready var memory_scene = preload("res://Scenes/Memory.tscn")
@onready var info: AnimationPlayer = $Info

var offer_num = 8
var offers = []
var weights = [["common", 65], ["rare", 25], ["legendary", 10]]

var player_in_radius = false

func _ready() -> void:
	Global.main.screenspace_hide_all()
	Global.main.screenspace_enable("comb")
	Global.main.screenspace_enable("drift2")
	Global.combo = 1.0
	randomize()
	Global.player.attack_disabled = true
	generate_memories()

func generate_memories():
	offer_num = Global.run_memories("memory_number", randi_range(OFFER_RANGE[0], OFFER_RANGE[1]))
	#var potential_offers : Array = []
	#for offer in Global.avalable_memories:
		#var add = true
		#for mem in Global.current_memories:
			#if offer["name"] == mem["name"]:
				#add = false
		#
		#if add:
			#potential_offers.append(offer)
	var exclude : Array = []
	for i in range(offer_num):
		var rarity
		var memory
		var count = 0
		while (not memory or Global.has_memory(memory)) and count < 100:
			rarity = Global.random_weighted(weights)[0]
			memory = Global.random_memory(rarity, exclude)
			count += 1
		#memory = Global.avalable_memories[20]
		if count < 100:
			print(memory["name"])
			
			var price = Global.run_memories("memory_price", Global.random_price(memory["rarity"]))
			exclude.append(memory["name"])
			offers.append([memory, price])
		else:
			offer_num -= 1
		
var first = true
func show_memories():
	if not first: info.play("info_out")
	else : first = false
	if offers.size() != 0:
		for i in range(offers.size()):
			if player_in_radius:
				var offer_memory = offers[i][0]
				var offer_price = offers[i][1]
				var inst = memory_scene.instantiate()
				
				inst.memory_name = offer_memory["name"]
				inst.description = offer_memory["description"]
				inst.rarity = offer_memory["rarity"]
				inst.icon = offer_memory["icon"]
				inst.cost = offer_price
				inst.index = i
				inst.consts = offer_memory["constants"]
				inst.target_pos = -Vector2.RIGHT.rotated((PI / (offer_num - 1)) * i) * SPREAD_DISATANCE
				
				$Offers.add_child(inst)
				await get_tree().create_timer(WAIT).timeout
			else:
				hide_memories()
				break
	else:
		printerr("Show memories called but memories not generated")

func hide_memories():
	info.play("info_in")
	$InfoDing.play()
	for child in $Offers.get_children():
		child.delete()
	

func delete_memory(index: int):
	offers.remove_at(index)
	offer_num -= 1
	hide_memories()
	show_memories()
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_radius = true
		show_memories()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_radius = false
		hide_memories()
		

	
