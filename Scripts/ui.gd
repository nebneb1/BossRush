extends SubViewportContainer

@onready var health_text: RichTextLabel = $Main/UI/VBoxContainer/Node2D/HealthText
@onready var combo_text: RichTextLabel = $Main/UI/VBoxContainer/Node2D2/ComboText
@onready var item_container: HBoxContainer = $Main/UI/VBoxContainer/Node2D3/ItemContainer
@onready var points_text: RichTextLabel = $Main/UI/VBoxContainer/Node2D4/PointsText
@onready var boss_health: RichTextLabel = $Main/UI/VBoxContainer/Node2D5/BossHealth

@onready var hit: AnimationPlayer = $Main/UI/UIhit
@onready var esc: AnimationPlayer = $Node2D6/esc

func _process(delta: float) -> void:
	
	health_text.text = "[tornado radius=0.5][color=light_blue]Health: " + str(Global.health) + "/" + str(Global.max_health)
	combo_text.text = "[tornado radius=0.5][color=light_blue]Combo: " + str(snapped(Global.combo, 0.1)) + "x/" + str(snapped(Global.max_combo, 0.1)) + "x"
	if Global.points_gained > 0:
		points_text.text = "[tornado radius=0.5][color=light_blue]Points: " + str(snapped(Global.points, 1.0)) + " + " +  str(snapped(Global.points_gained, 1.0))
	else:
		points_text.text = "[tornado radius=0.5][color=light_blue]Points: " + str(Global.points)
	boss_health.text = "[tornado radius=0.5][color=light_blue]Boss: " + str(snapped(Global.curr_boss_health, 1.0)) + "/" + str(snapped(Global.curr_boss_max_health, 1.0))

func play_health_hit():
	hit.play("HealthHit")

func play_combo_down():
	hit.play("ComboDown")

func play_combo_up():
	hit.play("ComboUp")

func play_fade():
	hit.play("fade_out")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		esc.play("in")
	elif event.is_action_released("esc"):
		esc.play("out")

