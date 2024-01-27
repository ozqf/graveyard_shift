extends Node

@onready var _animator:AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_animator.connect("animation_finished", _on_anim_finished)

func play_fire() -> void:
	_animator.play("fire")

func _on_anim_finished(_animName:String) -> void:
	if _animName != "idle":
		_animator.play("idle")

func is_ready() -> bool:
	return _animator.current_animation == "idle"
