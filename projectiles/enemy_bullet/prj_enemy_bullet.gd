extends Area3D

@onready var _launchInfo = $ProjectileLaunchInfo
@onready var _hitInfo:HitInfo = $HitInfo

var velocity:Vector3 = Vector3()
var _time:float = 0.0

func _ready():
	self.connect("area_entered", _on_touched_area)
	self.connect("body_entered", _on_touched_body)
	pass

func _on_touched_body(_body:Node3D) -> void:
	queue_free()

func _on_touched_area(_area:Area3D) -> void:
	var result:int = Game.try_hit(_area, _hitInfo)
	if result == Game.HIT_RESPONSE_SELF_HIT:
		return
	queue_free()

func hit(_incomingHit:HitInfo, _victimNode:Node) -> int:
	if _incomingHit.sourceId == _hitInfo.sourceId:
		return Game.HIT_RESPONSE_SELF_HIT
	if !Game.is_hit_valid(_incomingHit.teamId, _hitInfo.teamId):
		return Game.HIT_RESPONSE_TEAM_MATE
	
	Game.gfx_spawn_quickdraw_cancel(self.global_position)
	queue_free()
	return _incomingHit.damage

func get_launch_info() -> ProjectileLaunchInfo:
	return _launchInfo

func launch() -> void:
	_hitInfo.teamId = _launchInfo.teamId
	_hitInfo.sourceId = _launchInfo.sourceId
	global_position = _launchInfo.origin
	ZqfUtils.look_at_safe(self, _launchInfo.origin + _launchInfo.forward)
	velocity = _launchInfo.forward.normalized() * 40.0

func _physics_process(_delta:float):
	_time += _delta
	if _time > 30.0:
		self.queue_free()
		return
	self.global_position += velocity * _delta
