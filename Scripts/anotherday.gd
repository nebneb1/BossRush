extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("hide")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	Global.next_scene()
