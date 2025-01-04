extends Node2D

func _input(event: InputEvent) -> void: 
	$Main.push_input(event)
