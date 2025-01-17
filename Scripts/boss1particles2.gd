extends GPUParticles2D
var LIFETIME = 0.5
var time = 0.0

func _process(delta: float) -> void:
	time += delta
	if time >= LIFETIME:
		queue_free()
