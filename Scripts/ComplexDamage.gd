extends Area2D

@export var damage : int = 1
@export var collision_sprite : Node2D
@export_range(2, 50) var epsilon : int

func _ready() -> void:
	update_collisions()

var prev_frame_info : Array = []
func _process(delta: float) -> void:
	if collision_sprite is AnimatedSprite2D:
		if prev_frame_info != [collision_sprite.animation, collision_sprite.frame]:
			update_collisions()
		
		prev_frame_info = [collision_sprite.animation, collision_sprite.frame]
	
	

func update_collisions():
	var texture : Texture2D
	if collision_sprite is AnimatedSprite2D:
		texture = collision_sprite.sprite_frames.get_frame_texture(collision_sprite.animation, collision_sprite.frame)
	elif collision_sprite is Sprite2D:
		texture = collision_sprite.texture
		
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(texture.get_image())
	
	var polys = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, texture.get_size()), epsilon)
	for child in get_children():
		child.free()
	
	for poly in polys:
		var collision_polygon := CollisionPolygon2D.new()
		collision_polygon.polygon = poly
		collision_polygon.position -= Vector2(bitmap.get_size()/2)
		add_child(collision_polygon)
	
	
