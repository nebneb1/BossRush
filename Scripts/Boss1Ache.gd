extends Boss

@export var sprite : AnimatedSprite2D

@onready var particle_scene = preload("res://Scenes/boss1particles2.tscn")
@export var particle_parent : Node
@export_range(2, 20) var epsilon = 5 

func _ready() -> void:
	boss_name = "ache"

func _process(delta: float) -> void:
	update_particles()



func update_particles():
	var texture : Texture2D
	texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
		
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(texture.get_image())
	
	var polys = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, texture.get_size()), epsilon)
	for child in particle_parent.get_children():
		child.free()
	

	for poly in polys:
		for point in poly:
			var inst = particle_scene.instantiate()
			inst.position  = point
			particle_parent.add_child(inst)
		#var collision_polygon := CollisionPolygon2D.new()
		#collision_polygon.polygon = poly
		#collision_polygon.position -= Vector2(bitmap.get_size()/2)
		#add_child(collision_polygon)
	
