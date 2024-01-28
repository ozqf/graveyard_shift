extends Node3D

@onready var _launchInfo = $projectile_launch_info

var velocity:Vector3 = Vector3()
var _time:float = 0.0

func _ready():
	$Area3D.connect("area_entered", _on_touched_area)
	$Area3D.connect("body_entered", _on_touched_body)
	pass

func _on_touched_body(_body:Node3D) -> void:
	queue_free()

func _on_touched_area(_area:Area3D) -> void:
	queue_free()

func get_launch_info() -> ProjectileLaunchInfo:
	return _launchInfo

func launch() -> void:
	global_position = _launchInfo.origin
	ZqfUtils.look_at_safe(self, _launchInfo.origin + _launchInfo.forward)
	velocity = _launchInfo.forward.normalized() * 25.0

func _physics_process(_delta:float):
	_time += _delta
	if _time > 30.0:
		self.queue_free()
		return
	self.global_position += velocity * _delta
