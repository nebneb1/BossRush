extends AudioStreamPlayer

func _process(delta: float) -> void:
	if not playing:
		play()
