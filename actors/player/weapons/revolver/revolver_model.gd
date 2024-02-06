extends Node

signal round_was_chambered()
signal holster_finished()

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _muzzleFlashSmall:ZqfTimedHide3D = $root/muzzle_flash_small
@onready var _muzzleFlashCross:ZqfTimedHide3D = $root/muzzle_flash_cross

const FLAG_DONT_PLAY_IDLE_AFTER:int = (1 << 0)
const FLAG_CHAMBER_ROUND_AFTER:int = (1 << 1)

var _animProps:Dictionary = {
	"style_spin": {
		"flags": FLAG_CHAMBER_ROUND_AFTER
	},
	"style_spin_back": {
		"flags": FLAG_CHAMBER_ROUND_AFTER
	}
}

func _ready() -> void:
	_animator.connect("animation_finished", _on_anim_finished)

func play_spin_forward() -> void:
	if randf() > 0.5:
		_animator.play("style_spin")
	else:
		_animator.play("style_spin_back")

func play_holster() -> void:
	_animator.play("holster")

func play_fire(superShotWeight) -> void:
	
	_animator.play("fire")
	_animator.seek(0)
	if superShotWeight > 0.0:
		_muzzleFlashCross.run(0.05)
	else:
		_muzzleFlashSmall.run(0.05)

func _on_anim_finished(_animName:String) -> void:
	if _animProps.has(_animName):
		if _animProps[_animName].flags & FLAG_CHAMBER_ROUND_AFTER != 0:
			self.emit_signal("round_was_chambered")
	if _animName == "holstered":
		return
	if _animName == "holster":
		self.emit_signal("holster_finished")
		_animator.play("holstered")
		return
	if _animName != "idle":
		_animator.play("idle")

func is_ready() -> bool:
	return _animator.current_animation == "idle"

func is_holstered() -> bool:
	return _animator.current_animation == "holstered"
