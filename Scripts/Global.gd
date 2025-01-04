extends Node

const MAX_COMBO = 8.0
var combo = 1.0

func _process(delta: float):
	combo = clamp(combo, 1.0, MAX_COMBO)
