extends Node2D

var memory_name = "placeholder"
var description = "placeholder"
var rarity = "common"
var icon : Resource
var cost = 100
var index = 0

const SPEED = 4.0
const HOVER_RADIUS = 14.0

var target_pos : Vector2

#all of these bools are dumb and i really shouldnt be programming like this
var enabled = false
var deleting = false
var mouse_in_radius = false
var try_again = false

func _ready() -> void:
	$VBoxContainer/Name.text = "[center][tornado radius=5.0][color=pale_turquoise]" + memory_name
	$VBoxContainer/Description.text = "[center][tornado radius=1.0][color=plum]" + description
	$VBoxContainer/Cost.text = "[center][tornado radius=1.0][color=pink]" + str(cost) + " Score"
	if icon: $VBoxContainer/Icon.texture = icon
	$Spawn.pitch_scale = 4.0 + index/10.0
	$Spawn.play()

func _process(delta: float) -> void:
	if not enabled and not deleting:
		position = position.lerp(target_pos, delta * SPEED)
		if position.distance_to(target_pos) <= 1.0:
			enabled = true
	
	if deleting and not $AnimationPlayer.is_playing():
		queue_free()
		
	if get_viewport().get_mouse_position().distance_to(global_position) <= HOVER_RADIUS:
		if not mouse_in_radius or try_again:
			mouse_in_radius = true
			mouse_entered()
	else:
		if mouse_in_radius:
			mouse_in_radius  = false
			mouse_exited()
			

func delete():
	enabled = false
	if Global.active_hover == self: Global.active_hover = null
	$AnimationPlayer.play("fade", 0.5, randf_range(0.5,1.5))
	deleting = true

func mouse_entered() -> void:
	if enabled:
		try_again = false
		if $AnimationPlayer.is_playing():$AnimationPlayer.play("show", 0.5)
		else: $AnimationPlayer.play("show")
		Global.active_hover = self
	else:
		try_again = true
	


func mouse_exited() -> void:
	if enabled:
		if $AnimationPlayer.is_playing():$AnimationPlayer.play("hide", 0.5)
		else: $AnimationPlayer.play("hide")
		if Global.active_hover == self: Global.active_hover = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_purchase") and Global.active_hover == self and Global.score >= cost and memory_name != "placeholder":
		$Purchase.play()
		Global.score -= cost
		Global.add_memory(memory_name)
		get_node("../../").delete_memory(index)
		delete()

func hover_play_sound():
	if Global.active_hover == self:
		$Hover.play()
