extends Node
class_name PlayerAttack

var _prjThrownCard = preload("res://projectiles/thrown_card/prj_thrown_card.tscn")

@onready var _aimRay:RayCast3D = $aim_ray
@onready var _leftTimer:Timer = $left_timer
@onready var _rightTimer:Timer = $right_timer
@onready var _revolver = $hands/left/revolver
@onready var _rightHand:Node3D = $hands/right

@onready var _revolverHit:HitInfo = $revolver_hit

var shots:int = 6

func _ready() -> void:
	_revolverHit.teamId = Game.TEAM_ID_PLAYER

func write_hud_status(target:HudStatus) -> void:
	target.bullets = shots

func _process(delta):
	pass

func _throw_card() -> void:
	var prj = _prjThrownCard.instantiate()
	Game.get_actor_root().add_child(prj)
	var info:ProjectileLaunchInfo = prj.get_launch_info()
	info.origin = _rightHand.global_position
	info.forward = -_rightHand.global_transform.basis.z
	prj.launch()
	pass

func _tick_revolver(_delta:float, input:PlayerInput) -> void:
	if !_revolver.is_ready():
		return
	
	if input.attack1:
		_revolver.play_fire()
		var victim = _aimRay.get_collider()
		if victim !=  null:
			var pos:Vector3 = _aimRay.get_collision_point()
			var normal:Vector3 = _aimRay.get_collision_normal()
			var result:int = Game.try_hit(victim, _revolverHit)
			if result == Game.HIT_RESPONSE_WHIFF:
				Game.gfx_spawn_bullet_wall_impact(pos, normal)
		return
	
	if input.style:
		_revolver.play_spin_forward()
		return

func tick(_delta:float, input:PlayerInput) -> void:
	_tick_revolver(_delta, input)
	
	if input.attack2 && _rightTimer.is_stopped():
		_rightTimer.start(0.1)
		_rightTimer.paused = false
		_throw_card()
		return
	
