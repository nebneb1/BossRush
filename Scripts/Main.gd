extends Control

@export var viewport : Node

const SCENES : Dictionary = {
	"ache": preload("res://Scenes/Boss1.tscn"),
	"shop": preload("res://Scenes/ShopScene.tscn")
}

func _ready() -> void:
	$Transitions.show()
	fake_trans_to_scene(Callable(self, "empty_method"), "fade_from_black", 3.0)
	Global.main = self

	
func empty_method():
	pass

func switch_scene(scene : String):
	for child in viewport.get_children(): child.queue_free()
	viewport.add_child(SCENES[scene].instantiate())

# valid types are: fade_to_black
func trans_to_scene(scene : String, type : String, time : float):
	print(type, " to ", scene)
	match type:
		"fade_to_black":
			var tween = create_tween()
			tween.tween_property($Transitions/FadeToBlack, "color:a", 1.0, time)
			await tween.finished
			switch_scene(scene)
			var tween2 = create_tween()
			tween2.tween_property($Transitions/FadeToBlack, "color:a", 0.0, time)

func fake_trans_to_scene(after : Callable, type : String, time : float):
	match type:
		"fade_to_black":
			var tween = create_tween()
			tween.tween_property($Transitions/FadeToBlack, "color:a", 1.0, time)
			await tween.finished
			after.call()
			var tween2 = create_tween()
			tween2.tween_property($Transitions/FadeToBlack, "color:a", 0.0, time)
		
		"fade_from_black":
			$Transitions/FadeToBlack.color.a = 1.0
			var tween2 = create_tween()
			tween2.tween_property($Transitions/FadeToBlack, "color:a", 0.0, time)

	
