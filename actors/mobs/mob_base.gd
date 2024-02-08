extends CharacterBody3D
class_name MobBase

enum MobBaseState {
	Idle,
	Hunting,
	Dazed,
	Stunned,
	Dying,
	Dead
}

enum MobHuntState {
	Chase,
	WindUp,
	Action,
	WindDown
}

@onready var _launchInfo:MobLaunchInfo = $MobLaunchInfo
@onready var _navAgent:ZqfNavAgent = $ZqfNavAgent
@onready var _thinkInfo:MobThinkInfo = $MobThinkInfo
@onready var _mobBaseThinkTimer:Timer = $mob_base_think_timer

var teamId:int = Game.TEAM_ID_ENEMY

var _baseState:MobBaseState = MobBaseState.Idle
var _huntState:MobHuntState = MobHuntState.Chase

var _health:float = 100.0
var _dead:bool = false

var uuid:String = ""

func _ready() -> void:
	print("Mob ready")
	uuid = UUID.v4()
	_mobBaseThinkTimer.connect("timeout", _on_think_timout)
	_mobBaseThinkTimer.start()

func die() -> void:
	if _dead:
		return
	var grp:String = Game.GROUP_GAME_EVENTS
	var fn:String = Game.FN_GAME_EVENT_MOB_DIED
	get_tree().call_group(grp, fn, self, _launchInfo.tag)
	_dead = true
	self.queue_free()
	pass

func hit(_hitInfo:HitInfo, _victimNode:Node) -> int:
	if _hitInfo.sourceId == uuid:
		return Game.HIT_RESPONSE_SELF_HIT
	if !Game.is_hit_valid(_hitInfo.teamId, teamId):
		return Game.HIT_RESPONSE_WHIFF
	if _dead:
		return Game.HIT_RESPONSE_IS_DEAD
	
	var inflicted:float = _hitInfo.damage
	var headShot:bool = false
	if _victimNode.name == "hitbox2":
		headShot = true
		inflicted *= 2
	_health -= inflicted
	
	if _health <= 0.0:
		if headShot:
			print("Headshot!")
			var p:Vector3 = _victimNode.global_position
			Game.gfx_spawn_pop_blood_impact(p, _hitInfo.direction)
			Game.gfx_spawn_pop_blood_impact(p, -_hitInfo.direction)
		_spawn_corpse()
		die()
		return int(inflicted)
	else:
		var gfxForward:Vector3 = -_hitInfo.direction
		Game.gfx_spawn_bullet_blood_impact(_hitInfo.position, gfxForward)
	
	return int(inflicted)

func _spawn_corpse() -> void:
	pass

func get_launch_info() -> MobLaunchInfo:
	return _launchInfo

func launch() -> void:
	pass

func receive_taunt() -> void:
	pass

func _refresh_think_info() -> void:
	_thinkInfo.targetInfo = Game.get_player_target()
	
	if _thinkInfo.targetInfo == null || !_thinkInfo.targetInfo.isValid:
		_thinkInfo.hasTarget = false
		return
	
	_thinkInfo.hasTarget = true

	var from:Vector3 = self.global_position
	var to:Vector3 = _thinkInfo.targetInfo.footPosition
	_thinkInfo.distToTargetSqrTrue = from.distance_squared_to(to)
	
	# calc flat distance
	to.y = from.y
	_thinkInfo.distToTargetSqrFlat = from.distance_squared_to(to)

func _look_toward_flat(to:Vector3) -> void:
	var from:Vector3 = self.global_position
	var d:Vector2 = Vector2(-(to.x - from.x), (to.z - from.z))
	self.rotation.y = d.angle() + (PI * 0.5)

func _physics_process(_delta:float) -> void:
	_refresh_think_info()
	match _baseState:
		MobBaseState.Hunting:
			if !_thinkInfo.hasTarget:
				_change_base_state(MobBaseState.Idle)
				return
			_tick_hunt(_delta)
		MobBaseState.Idle:
			_tick_idle(_delta)
		_:
			_change_base_state(MobBaseState.Idle)

#################################################################################
# Utility functions
#################################################################################

func _approach_move_target(_delta:float) -> void:
	_navAgent.set_move_target(_thinkInfo.targetInfo.footPosition)
	_look_toward_flat(_thinkInfo.targetInfo.footPosition)
	_navAgent.physics_tick(_delta)
	self.velocity = _navAgent.velocity
	move_and_slide()

func _update_targeting_ray(ray:RayCast3D, target:Vector3) -> void:
	ZqfUtils.look_at_safe(ray, target)
	var dist:float = ray.global_position.distance_to(target)
	ray.target_position = Vector3(0, 0, -dist)
	_thinkInfo.hasLineOfSight = !ray.is_colliding()

#################################################################################
# State
#################################################################################

func _change_base_state(newBaseState:MobBaseState) -> void:
	#var _prevState:MobBaseState = _baseState
	_baseState = newBaseState
	match _baseState:
		MobBaseState.Hunting:
			_mobBaseThinkTimer.start(0.5)
			_mobBaseThinkTimer.paused = false
		MobBaseState.Idle:
			_mobBaseThinkTimer.start(0.5)
			_mobBaseThinkTimer.paused = false

func _on_think_timout() -> void:
	match _baseState:
		MobBaseState.Hunting:
			_tock_hunt()
		MobBaseState.Idle:
			_tock_idle()

#################################################################################
# Tick
#################################################################################

func _tick_idle(_delta:float) -> void:
	pass

func _tick_hunt(_delta:float) -> void:
	pass

#################################################################################
# Tock
#################################################################################

func _tock_idle() -> void:
	if _thinkInfo.hasTarget:
		_change_base_state(MobBaseState.Hunting)
		return
	_mobBaseThinkTimer.start(0.5)
	_mobBaseThinkTimer.paused = false

func _tock_hunt() -> void:
	pass
