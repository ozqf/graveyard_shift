extends Node
class_name PlayerAttack

# sounds
var _sndPistolFire = preload("res://shared/sounds/weapons/pistol_fire.wav")

# projectiles
var _prjThrownCard = preload("res://projectiles/thrown_card/prj_thrown_card.tscn")
var _ricochetScene = preload("res://actors/player/weapons/ricochet_shot.tscn")

const MAX_SUPER_SHOT_DURATION:float = 2.0

@onready var _aimRay:RayCast3D = $aim_ray
@onready var _tauntRay:RayCast3D = $taunt_ray
@onready var _leftTimer:Timer = $left_timer
@onready var _rightTimer:Timer = $right_timer
@onready var _revolver = $hands/right/revolver

@onready var _rightHand:Node3D = $hands/right
@onready var _leftHand:Node3D = $hands/left

@onready var _revolverHit:HitInfo = $revolver_hit

var _rayParams:PhysicsRayQueryParameters3D

var shots:int = 6
var _superShotWeight:float = 0.0
var _inChain:bool = false
var _ignore = []

#var _focusTime:float = 0.0
#var _inFocus:bool = true

var uuid:String = ""

func _ready() -> void:
	_revolverHit.teamId = Game.TEAM_ID_PLAYER
	_revolver.connect("round_was_chambered", _on_round_was_chambered)
	_rayParams = ZqfUtils.create_default_hitscan_params([], _aimRay.collision_mask)

func add_attack_ignore_node(node) -> void:
	_ignore.push_back(node)

func add_revolver_bullets(amount:float) -> float:
	if shots < 6:
		shots += int(amount)
		if shots > 6:
			shots = 6
		return amount
	return 0

func write_hud_status(target:HudStatus) -> void:
	target.bullets = shots
	target.superShotWeight = _superShotWeight

func _throw_card() -> void:
	var prj = _prjThrownCard.instantiate()
	Game.get_actor_root().add_child(prj)
	var info:ProjectileLaunchInfo = prj.get_launch_info()
	info.origin = _leftHand.global_position
	info.forward = -_leftHand.global_transform.basis.z
	info.teamId = Game.TEAM_ID_PLAYER
	info.sourceId = uuid
	prj.launch()

func _on_round_was_chambered() -> void:
	#_superShotWeight = 1
	if shots < 6:
		shots += 1

func _taunt_at_aim_target() -> void:
	var victim = _tauntRay.get_collider()
	if victim != null && victim.has_method("receive_taunt"):
		victim.receive_taunt()

func _spawn_ricochet(pos:Vector3, forward:Vector3, numRicochets:int = 0) -> void:
	var node = ZqfUtils.create_node3d_instance(_ricochetScene, Game.get_actor_root(), pos)
	ZqfUtils.look_at_safe(node, pos + forward)
	node.ricochets = numRicochets
	node.hitInfo.copy_from(_revolverHit)
	node.scale = Vector3(1, 1, 100)

func _ray_cast() -> Dictionary:
	return {}

func _fire_revolver() -> void:
	_revolverHit.sourceId = uuid
	var ricochets:int = 0
	if _superShotWeight > 0.0:
		_revolverHit.damage = 20
		_revolverHit.isQuickShot = true
		ricochets = 3
	else:
		_revolverHit.damage = 20
		_revolverHit.isQuickShot = false
	shots -= 1
	GameAudio.play_pistol_fire(self.global_position)
	_revolver.play_fire(_superShotWeight)
	
	# ew copy
	_rayParams.exclude = _ignore.duplicate()
	
	var t:Transform3D = _aimRay.global_transform
	var forward:Vector3 = -t.basis.z
	_rayParams.from = t.origin
	_rayParams.to = _rayParams.from + (forward * 1000.0)
	var scanning:bool = true
	var escape:int = 0
	while scanning:
		escape += 1
		if escape > 100:
			print("Revolver raycast ran away!")
			break;
		# _aimRay is passed just because we need a node3d to get world from
		var hit:Dictionary = ZqfUtils.hitscan(_aimRay, _rayParams)
		if hit.is_empty():
			# missed!
			scanning = false
			continue
		var response:int = Game.try_hit(hit.collider, _revolverHit)
		if response == Game.HIT_RESPONSE_WHIFF:
			Game.gfx_spawn_bullet_wall_impact(hit.position, hit.normal)
			if ricochets <= 0:
				scanning = false
				continue
			# reset record of actors we've hit as we've changed direction
			# also, ew copy again :(
			_rayParams.exclude = _ignore.duplicate()
			
			ricochets -= 1
			# ...the normal isn't necessarily normalised...
			forward = (forward).bounce(hit.normal.normalized())
			_rayParams.from = hit.position
			_rayParams.to = forward * 1000.0
			_spawn_ricochet(_rayParams.from, forward, 0)
			continue
		elif response > 0:
			if _revolverHit.isQuickShot:
				# penetrate
				_rayParams.exclude.push_back(hit.rid)
				_rayParams.from = hit.position
				_rayParams.to = _rayParams.from + (forward * 1000.0)
				continue
			scanning = false
			continue
		elif response == Game.HIT_RESPONSE_TEAM_MATE:
			# continue
			_rayParams.exclude.push_back(hit.rid)
			_rayParams.from = hit.position
			_rayParams.to = _rayParams.from + (forward * 1000.0)
		else:
			scanning = false
			continue
	#var victim = _aimRay.get_collider()
	#if victim !=  null:
	#	_revolverHit.direction = -_aimRay.global_transform.basis.z
	#	_revolverHit.position = _aimRay.get_collision_point()
	#	var normal:Vector3 = _aimRay.get_collision_normal()
	#	var result:int = Game.try_hit(victim, _revolverHit)
	#	if result == Game.HIT_RESPONSE_WHIFF:
	#		Game.gfx_spawn_bullet_wall_impact(_revolverHit.position, normal)
	#		# ricochet?
	#		if _revolverHit.isQuickShot:
	#			var bounceForward:Vector3 = _revolverHit.direction
	#			var reflectV:Vector3 = normal.normalized()
	#			bounceForward = _revolverHit.direction.bounce(reflectV)
	#			_spawn_ricochet(_revolverHit.position, bounceForward, ricochets)
	#	elif result > 0:
	#		if _superShotWeight > 0.0:
	#			#GameTime.add_effect("quick_shot", 0.15, 2.0)
	#			_inChain = true
	#	elif result < 0:
	#		_superShotWeight = 0.0
	#		_inChain = false
	#	#else:
	#	#	_superShotWeight = 1
	#else:
	#	_superShotWeight = 0.0
	#	_inChain = false

func _tick_revolver(_delta:float, input:PlayerInput) -> void:
	if _revolver.is_holstered():
		_taunt_at_aim_target()
	
	if input.attack1Tap && shots > 0:
		_fire_revolver()
		return
	
	if (input.style && shots >= 6 && _revolver.is_ready()):
		_revolver.play_holster()
		return
	
	if _revolver.is_ready() && (shots < 6):
		#if shots == 6:
		#	_taunt_at_aim_target()
		_revolver.play_spin_forward()
		#_revolver.play_holster()
		return

func tick(_delta:float, input:PlayerInput) -> void:
	#if _inChain:
	#	Engine.time_scale = 0.25
	#else:
	#	Engine.time_scale = 1.0
	
	if input.inputDir.y < 0.0:
		GameTime.add_effect("player", 0.25, 999)
	else:
		GameTime.remove_effect("player")
	#if _focusTime > 0.0 && input.inputDir.y < 0.0:
	#	_focusTime -= _delta
	#	if _focusTime > 0.0:
	#		GameTime.run(0.25, 1)
	#if _inFocus == true:
	#	_focusTime -= _delta
	#
	#	GameTime.run(0.25, _focusTime)
	#	pass
	
	
	if _revolver.is_holstered():
		_superShotWeight = MAX_SUPER_SHOT_DURATION
	else:
		#if _superShotWeight > 0.0 && shots > 0 && _inChain:
		#	Engine.time_scale = 0.25
		_superShotWeight -= _delta
		if _superShotWeight < 0.0:
			_superShotWeight = 0.0
			_inChain = false
	
	_tick_revolver(_delta, input)
	
	if input.attack2 && _rightTimer.is_stopped():
		_rightTimer.start(0.1)
		_rightTimer.paused = false
		_throw_card()
		return
	
