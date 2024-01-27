extends Node

var _prjThrownCard = preload("res://projectiles/thrown_card/prj_thrown_card.tscn")

@onready var _aimRay:RayCast3D = $aim_ray
@onready var _leftTimer:Timer = $left_timer
@onready var _rightTimer:Timer = $right_timer
@onready var _revolver = $hands/left/revolver
@onready var _rightHand:Node3D = $hands/right

func _ready():
	pass

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

func tick(_delta:float, attack1:bool, attack2:bool) -> void:
	if attack1 && _revolver.is_ready():
		_revolver.play_fire()
		
		if _aimRay.is_colliding():
			var pos:Vector3 = _aimRay.get_collision_point()
			var normal:Vector3 = _aimRay.get_collision_normal()
			Game.gfx_spawn_bullet_wall_impact(pos, normal)
	
	if attack2 && _rightTimer.is_stopped():
		_rightTimer.start(0.1)
		_rightTimer.paused = false
		_throw_card()
		pass
