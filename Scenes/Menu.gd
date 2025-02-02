extends Node2D
@onready var SELECTABLE = [$ViewportContainer/Main/SubViewportContainer/Main/Node2D2/Play, $ViewportContainer/Main/SubViewportContainer/Main/Node2D3/Music, $ViewportContainer/Main/SubViewportContainer/Main/Node2D4/SFX]
const SCENE_MANAGER = preload("res://Scenes/SceneManager.tscn")

var music = 10
var SFX = 10
var pre_stuff ="[tornado radius=0.5][color=light_blue][center]"
#const SELECT_TEXT = [{"selected" : "[tornado radius=0.5][color=light_blue][center]<Play>", "unselected" : "[tornado radius=0.5][color=light_blue][center]Play"}, ]
var text = ["Play", "Music : " + str(music), "SFX" + str(SFX)]
var selected : int = 0

func _process(delta: float) -> void:
	text = ["Play", "Music : " + str(music), "SFX : " + str(SFX)]
	for select in range(SELECTABLE.size()):
		if select == selected:
			SELECTABLE[select].text = pre_stuff + "<" + text[select] + ">"
		else:
			SELECTABLE[select].text = pre_stuff + text[select]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter") and selected == 0:
		selected = 10
		$AnimationPlayer.play("fadeout")
		$Play.play()
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_packed(SCENE_MANAGER)
		
	
	if event.is_action_pressed("up"):
		$SelectMove.play()
		selected = clamp(selected - 1, 0, SELECTABLE.size()-1)
	elif event.is_action_pressed("down"):
		$SelectMove.play()
		selected = clamp(selected + 1, 0, SELECTABLE.size()-1)
	if event.is_action_pressed("left"):
		$SelectMove.play()
		if selected == 1:
			music = clamp(music - 1, 0, 10)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), clamp(linear_to_db(music/10.0), -100, 0.0))
		
		if selected == 2:
			SFX = clamp(SFX - 1, 0, 10)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), clamp(linear_to_db(SFX/20.0), -100, 0.0))
			
	if event.is_action_pressed("right"):
		$SelectMove.play()
		if selected == 1:
			music = clamp(music + 1, 0, 10)
			print(AudioServer.get_bus_index("Music"))
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), clamp(linear_to_db(music/10.0), -100, 0.0))
		
		if selected == 2:
			SFX = clamp(SFX + 1, 0, 10)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), clamp(linear_to_db(SFX/20.0), -100, 0.0))
