extends SubViewportContainer

@onready var health_text: RichTextLabel = $Main/UI/VBoxContainer/Node2D/HealthText
@onready var combo_text: RichTextLabel = $Main/UI/VBoxContainer/Node2D2/ComboText
@onready var item_container: HBoxContainer = $Main/UI/VBoxContainer/Node2D3/ItemContainer
@onready var points_text: RichTextLabel = $Main/UI/VBoxContainer/Node2D4/PointsText

@onready var hit: AnimationPlayer = $Main/UI/UIhit



func _process(delta: float) -> void:
	health_text.text = "[tornado radius=0.5][color=light_blue]Health: " + str(Global.health) + "/" + str(Global.max_health)
	combo_text.text = "[tornado radius=0.5][color=light_blue]Combo: " + str(snapped(Global.combo, 0.1)) + "x/" + str(snapped(Global.max_combo, 0.1)) + "x"
	points_text.text = "[tornado radius=0.5][color=light_blue]Points: " + str(Global.points)

func play_health_hit():
	hit.play("HealthHit")

func play_combo_down():
	hit.play("ComboDown")

func play_combo_up():
	hit.play("ComboUp")

func play_fade():
	hit.play("fade_out")


