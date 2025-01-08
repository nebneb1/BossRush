@tool
extends RichTextEffect
class_name Wack

var bbcode := "wack"


func _process_custom_fx(c: CharFXTransform):
	var cs := 1.0 * Vector2(0.5, -0.3)
	c.transform *= Transform2D.IDENTITY.translated(cs)
	c.transform *= Transform2D.IDENTITY.rotated((cos(c.relative_index + c.elapsed_time) + sin(0.6 + c.elapsed_time * 3.0)) * .125)
	c.transform *= Transform2D.IDENTITY.scaled(Vector2.ONE * (1.0 + cos(0.4 * .5 + c.relative_index * 3.0 + c.elapsed_time * 1.3) * .125))
	c.transform *= Transform2D.IDENTITY.translated(-cs)
	return true
