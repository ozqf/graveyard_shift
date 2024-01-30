extends Node
class_name MobBase

@onready var _launchInfo:MobLaunchInfo = $MobLaunchInfo

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
