extends Node

var teamId:int = Game.TEAM_ID_ENEMY

var _health:float = 100.0
var _dead:bool = false

func hit(_hitInfo:HitInfo) -> int:
	if !Game.is_hit_valid(_hitInfo.teamId, teamId):
		return Game.HIT_RESPONSE_WHIFF
	if _dead:
		return Game.HIT_RESPONSE_WHIFF
	_health -= _hitInfo.damage
	if _health <= 0.0:
		self.queue_free()
		return _hitInfo.damage
	
	
	return _hitInfo.damage
