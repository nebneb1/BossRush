extends Node2D

@onready var animation_player: AnimationPlayer = $ViewportContainer/Main/AnimationPlayer
@export var lowpass : AudioEffectLowPassFilter
var called = false
@onready var days_survived: RichTextLabel = $ViewportContainer/Main/SubViewportContainer/Main/Node2D2/DaysSurvived
@onready var score: RichTextLabel = $ViewportContainer/Main/SubViewportContainer/Main/Node2D3/Score


func _ready() -> void:
	animation_player.play("fade_in")
	days_survived.text = "[tornado radius=0.5][color=light_blue][center]days survived: " + str(Global.days_survived)
	score.text = "[tornado radius=0.5][color=light_blue][center]score: " + str(Global.points)
	UI.play_fade()
		
