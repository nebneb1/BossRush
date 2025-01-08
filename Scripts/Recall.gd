extends Node2D


const OFFER_RANGE = [6, 10]
const SPREAD_DISATANCE = 100.0
const WAIT = 0.1

@onready var memory_scene = preload("res://Scenes/Memory.tscn")

var offer_num = 8
var offers = []
var weights = [["common", 65], ["rare", 25], ["legendary", 10]]

var player_in_radius = false

func _ready() -> void:
	randomize()
	generate_memories()

func generate_memories():
	offer_num = randi_range(OFFER_RANGE[0], OFFER_RANGE[1])
	for i in range(offer_num):
		var rarity = Global.random_weighted(weights)[0]
		var memory = Global.random_memory(rarity)
		var price = Global.random_price(rarity)
		offers.append([memory, price])
		

func show_memories():
			
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
				inst.target_pos = -Vector2.RIGHT.rotated((PI / (offer_num - 1)) * i) * SPREAD_DISATANCE
				
				$Offers.add_child(inst)
				await get_tree().create_timer(WAIT).timeout
			else:
				hide_memories()
				break
	else:
		printerr("Show memories called but memories not generated")

func hide_memories():
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
		

	
