extends Node3D

@onready var _core:MeshInstance3D = $core
@onready var _timingAura:MeshInstance3D = $timing_aura

var _time:float = 0.0

func _ready():
	pass

func _refresh(weight:float) -> void:
	var coreScale:Vector3 = Vector3.ZERO.lerp(Vector3.ONE, weight)
	var timingScale:Vector3 = Vector3.ONE.lerp(Vector3.ZERO, weight)
	_core.scale = coreScale
	_timingAura.scale = timingScale
	pass

func _process(delta):
	_time += (delta * 4)
	var s:float = sin(_time)
	s += 1
	s /= 2
	_refresh(s)
	pass
