extends Node
class_name PlayerAttack

# projectiles
var _prjThrownCard = preload("res://projectiles/thrown_card/prj_thrown_card.tscn")
var _ricochetScene = preload("res://actors/player/weapons/ricochet_shot.tscn")

const MAX_SUPER_SHOT_DURATION:float = 2.0

@onready var _aimRay:RayCast3D = $aim_ray
@onready var _tauntRay:RayCast3D = $taunt_ray
#@onready var _leftTimer:Timer = $left_timer
@onready var _rightTimer:Timer = $right_timer
@onready var _revolver = $hands/right/revolver

#@onready var _rightHand:Node3D = $hands/right
@onready var _leftHand:Node3D = $hands/left

@onready var _spellUser:SpellUserInfo = $SpellUserInfo

@onready var _revolverHit:HitInfo = $revolver_hit

var _spellsNode:Node = null
var _spellSlots = []
var _spellSlotIndex:int = 0
var _pendingSpellSlotIndex:int = -1
var _rayParams:PhysicsRayQueryParameters3D

var shots:int = 6
var _superShotWeight:float = 0.0
var _inChain:bool = false
var _ignore = []

var _uuid:String = ""

func _ready() -> void:
	_revolverHit.teamId = Game.TEAM_ID_PLAYER
	_revolver.connect("round_was_chambered", _on_round_was_chambered)
	_rayParams = ZqfUtils.create_default_hitscan_params([], _aimRay.collision_mask)
	_spellUser.aimNode = _aimRay as Node3D
	_spellUser.leftHand = _leftHand as Node3D

func set_uuid(newUUID:String) -> void:
	_uuid = newUUID

func set_spells_node(spellsNode:Node) -> void:
	_spellsNode = spellsNode
	_spellSlots.push_back(spellsNode.get_node("Spell1"))
	_spellSlots.push_back(spellsNode.get_node("Spell2"))
	_spellSlots.push_back(spellsNode.get_node("Spell3"))
	_spellSlots.push_back(spellsNode.get_node("Spell4"))
	_spellSlots[0].attach(_spellUser)
	_spellSlots[1].attach(_spellUser)
	_spellSlots[2].attach(_spellUser)
	_spellSlots[3].attach(_spellUser)

func add_attack_ignore_node(node:Node) -> void:
	_ignore.push_back(node.get_rid())

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
	info.sourceId = _uuid
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
	_revolverHit.sourceId = _uuid
	var ricochets:int = 0
	_revolverHit.damage = 20
	if _superShotWeight > 0.0:
		_revolverHit.isQuickShot = true
		ricochets = 3
	else:
		_revolverHit.isQuickShot = false
	shots -= 1
	GameAudio.play_pistol_fire(self.global_position)
	_revolver.play_fire(_superShotWeight)
	
	# it seems that we can assign the ignore array but cannot insert to it
	# via the ray params. So maintain another list we will apply each iteration
	# Exclude must be mutable too so we can't use the original
	# also, ew copy
	var excludeList = _ignore.duplicate()
	
	var t:Transform3D = _aimRay.global_transform
	var forward:Vector3 = -t.basis.z
	_rayParams.from = t.origin
	_rayParams.to = _rayParams.from + (forward * 1000.0)
	var scanning:bool = true
	var escape:int = 0
	while scanning:
		escape += 1
		if escape > 100:
			# I'm great at while loops
			push_warning("Revolver raycast ran away!")
			break

		_rayParams.exclude = excludeList
		# _aimRay is passed just because we need a node3d to get world from
		# we don't actually use it for casting here
		var hit:Dictionary = ZqfUtils.hitscan(_aimRay, _rayParams)
		if hit.is_empty():
			# missed!
			break
		
		_revolverHit.position = hit.position
		_revolverHit.direction = forward
		var response:int = Game.try_hit(hit.collider, _revolverHit)
		if response > 0 || response == Game.HIT_RESPONSE_IS_DEAD:
			if _superShotWeight > 0.0:
				_superShotWeight = MAX_SUPER_SHOT_DURATION
			if _revolverHit.isQuickShot:
				# penetrate
				excludeList.push_back(hit.rid)
				_rayParams.from = hit.position
				_rayParams.to = _rayParams.from + (forward * 1000.0)
				continue
			break
		
		if response == Game.HIT_RESPONSE_WHIFF:
			Game.gfx_spawn_bullet_wall_impact(hit.position, hit.normal)
			if ricochets <= 0:
				break
			# reset record of actors we've hit as we've changed direction
			# also, ew copy again :(
			excludeList = _ignore.duplicate()
			ricochets -= 1
			var n:Vector3 = hit.normal
			if !n.is_equal_approx(Vector3.ZERO):
				forward = (forward).bounce(n)	
			else:
				# this occassionally happens for some reason...
				# ...just reflect straight back I guess
				forward = -forward
			_rayParams.from = hit.position
			_rayParams.to = forward * 1000.0
			_spawn_ricochet(_rayParams.from, forward, 0)
			continue
		
		if response == Game.HIT_RESPONSE_TEAM_MATE:
			# penetrate and continue
			excludeList.push_back(hit.rid)
			_rayParams.from = hit.position
			_rayParams.to = _rayParams.from + (forward * 1000.0)
			continue
		
		scanning = false

func _tick_revolver(_delta:float, input:PlayerInput) -> void:
	if _revolver.is_holstered():
		_taunt_at_aim_target()
		_superShotWeight = MAX_SUPER_SHOT_DURATION
	else:
		#if _superShotWeight > 0.0 && shots > 0 && _inChain:
		#	Engine.time_scale = 0.25
		_superShotWeight -= _delta
		if _superShotWeight < 0.0:
			_superShotWeight = 0.0
			_inChain = false
	
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

func _tick_cards(_delta:float, input:PlayerInput) -> void:
	if input.slot1Tap:
		_pendingSpellSlotIndex = 0
	if input.slot2Tap:
		_pendingSpellSlotIndex = 1
	if input.slot3Tap:
		_pendingSpellSlotIndex = 2
	if input.slot4Tap:
		_pendingSpellSlotIndex = 3
	
	if _pendingSpellSlotIndex != -1:
		_spellSlotIndex = _pendingSpellSlotIndex
		_pendingSpellSlotIndex = -1

	if input.attack2 && _rightTimer.is_stopped():
		_rightTimer.start(0.1)
		_rightTimer.paused = false
		_spellUser.sourceId = _uuid
		_spellSlots[_spellSlotIndex].cast(_spellUser)
		#_throw_card()
		return

func tick(_delta:float, input:PlayerInput) -> void:
	#if input.inputDir.y < 0.0:
	#	GameTime.add_effect("player", 0.25, 999)
	#else:
	#	GameTime.remove_effect("player")
	
	_tick_revolver(_delta, input)
	_tick_cards(_delta, input)
