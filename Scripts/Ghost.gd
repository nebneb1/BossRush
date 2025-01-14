extends Sprite2D

const FADE_SPEED = 0.2
const HUE_VARIATION = 0.1

var rotation_speed = randfn(0, 1.0)
var yvel = -randf_range(50, 300)/5
var xvel = randf_range(-25, 25)/5
#var color : Color = Color.DARK_MAGENTA
var color : Color = Color.DARK_BLUE
func _ready() -> void:
	color.h += randf_range(-HUE_VARIATION, HUE_VARIATION)
	color.a = 0.5
	var shader_material = material as ShaderMaterial
	shader_material.set_shader_parameter("GhostColor", color)

func _process(delta: float) -> void:
	var shader_material = material as ShaderMaterial
	var ghost_color = shader_material.get_shader_parameter("GhostColor")
	
	if ghost_color.a > 0.03:
		ghost_color.a -= delta * FADE_SPEED * (ghost_color.a * 4)
	else:
		ghost_color.a -= delta * FADE_SPEED * (ghost_color.a * 0.1)
	
	position += Vector2(xvel, yvel) * delta * (ghost_color.a * (1-ghost_color.a))*4
	rotation += rotation_speed * delta * (ghost_color.a * (1-ghost_color.a))*4
	if ghost_color.a <= 0.001:
		queue_free()
	
	
	#scale += Vector2.ONE * delta * FADE_SPEED * (ghost_color.a)
	
	shader_material.set_shader_parameter("GhostColor", ghost_color)

