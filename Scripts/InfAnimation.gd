extends GPUParticles2D

var TIME = 0.0
const SCALE = Vector2(000.0, 00.0)
func _process(delta: float) -> void:
	TIME += delta
	position = Vector2(cos(TIME), sin(TIME*2)) * SCALE + Vector2(320, 183)
