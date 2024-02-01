extends CharacterBody3D
class_name MobBase

@onready var _launchInfo:MobLaunchInfo = $MobLaunchInfo
@onready var _navAgent:ZqfNavAgent = $ZqfNavAgent
@onready var _thinkInfo:MobThinkInfo = $MobThinkInfo

var teamId:int = Game.TEAM_ID_ENEMY

var _health:float = 100.0
var _dead:bool = false

var uuid:String = ""

func _ready() -> void:
	print("Mob ready")
	uuid = UUID.v4()

func die() -> void:
	if _dead:
		return
	var grp:String = Game.GROUP_GAME_EVENTS
	var fn:String = Game.FN_GAME_EVENT_MOB_DIED
	get_tree().call_group(grp, fn, self, _launchInfo.tag)
	_dead = true
	self.queue_free()
	pass

func hit(_hitInfo:HitInfo) -> int:
	if !Game.is_hit_valid(_hitInfo.teamId, teamId):
		return Game.HIT_RESPONSE_WHIFF
	if _dead:
		return Game.HIT_RESPONSE_WHIFF
	
	_health -= _hitInfo.damage
	
	if _health <= 0.0:
		die()
		return _hitInfo.damage
	else:
		var gfxForward:Vector3 = -_hitInfo.direction
		Game.gfx_spawn_bullet_blood_impact(_hitInfo.position, gfxForward)
	
	return _hitInfo.damage

func get_launch_info() -> MobLaunchInfo:
	return _launchInfo

func launch() -> void:
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
	if !_thinkInfo.hasTarget:
		return
	if _thinkInfo.distToTargetSqrFlat < 12:
		return
	_navAgent.set_move_target(_thinkInfo.targetInfo.footPosition)
	_look_toward_flat(_thinkInfo.targetInfo.footPosition)
	_navAgent.physics_tick(_delta)
	#print("nav vel " + str(_navAgent.velocity))
	self.velocity = _navAgent.velocity
	move_and_slide()
