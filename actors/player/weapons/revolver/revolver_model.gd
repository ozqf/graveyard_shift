extends Node

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _muzzleFlashSmall:ZqfTimedHide3D = $root/muzzle_flash_small
@onready var _muzzleFlashCross:ZqfTimedHide3D = $root/muzzle_flash_cross

func _ready() -> void:
	_animator.connect("animation_finished", _on_anim_finished)

func play_spin_forward() -> void:
	_animator.play("style_spin")

func play_fire() -> void:
	_animator.play("fire")
	#_muzzleFlashSmall.run(0.1)
	_muzzleFlashCross.run(0.2)

func _on_anim_finished(_animName:String) -> void:
	if _animName != "idle":
		_animator.play("idle")

func is_ready() -> bool:
	return _animator.current_animation == "idle"
