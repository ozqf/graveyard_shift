extends Node
class_name PlayerAttack

# sounds
var _sndPistolFire = preload("res://shared/sounds/weapons/pistol_fire.wav")

# projectiles
var _prjThrownCard = preload("res://projectiles/thrown_card/prj_thrown_card.tscn")

@onready var _aimRay:RayCast3D = $aim_ray
@onready var _tauntRay:RayCast3D = $taunt_ray
@onready var _leftTimer:Timer = $left_timer
@onready var _rightTimer:Timer = $right_timer
@onready var _revolver = $hands/right/revolver

@onready var _rightHand:Node3D = $hands/right
@onready var _leftHand:Node3D = $hands/left

@onready var _revolverHit:HitInfo = $revolver_hit

var shots:int = 6
var _superShotWeight:float = 0.0

func _ready() -> void:
	_revolverHit.teamId = Game.TEAM_ID_PLAYER
	_revolver.connect("round_was_chambered", _on_round_was_chambered)

func write_hud_status(target:HudStatus) -> void:
	target.bullets = shots
	target.superShotWeight = _superShotWeight

func _throw_card() -> void:
	var prj = _prjThrownCard.instantiate()
	Game.get_actor_root().add_child(prj)
	var info:ProjectileLaunchInfo = prj.get_launch_info()
	info.origin = _leftHand.global_position
	info.forward = -_leftHand.global_transform.basis.z
	prj.launch()

func _on_round_was_chambered() -> void:
	_superShotWeight = 1
	if shots < 6:
		shots += 1

func _taunt_at_aim_target() -> void:
	var victim = _tauntRay.get_collider()
	if victim != null && victim.has_method("receive_taunt"):
		victim.receive_taunt()

func _tick_revolver(_delta:float, input:PlayerInput) -> void:
	if input.attack1Tap && shots > 0:
		if _superShotWeight > 0.0:
			_revolverHit.damage = 15
			_revolverHit.isQuickShot = true
		else:
			_revolverHit.damage = 10
			_revolverHit.isQuickShot = false
		shots -= 1
		GameAudio.play_pistol_fire(self.global_position)
		_revolver.play_fire(_superShotWeight)
		var victim = _aimRay.get_collider()
		if victim !=  null:
			_revolverHit.direction = -_aimRay.global_transform.basis.z
			_revolverHit.position = _aimRay.get_collision_point()
			var normal:Vector3 = _aimRay.get_collision_normal()
			var result:int = Game.try_hit(victim, _revolverHit)
			if result == Game.HIT_RESPONSE_WHIFF:
				Game.gfx_spawn_bullet_wall_impact(_revolverHit.position, normal)
			else:
				_superShotWeight = 1
		return
	
	if _revolver.is_ready() && (input.style || shots < 6):
		if shots == 6:
			_taunt_at_aim_target()
		_revolver.play_spin_forward()
		return

func tick(_delta:float, input:PlayerInput) -> void:
	_superShotWeight -= _delta
	if _superShotWeight < 0.0:
		_superShotWeight = 0.0
	
	_tick_revolver(_delta, input)
	
	if input.attack2 && _rightTimer.is_stopped():
		_rightTimer.start(0.1)
		_rightTimer.paused = false
		_throw_card()
		return
	
