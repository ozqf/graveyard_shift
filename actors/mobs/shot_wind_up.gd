extends Area3D
class_name ShotWindUp

signal WindUpHit(shotWindUpInstance, weight)

@onready var _core:MeshInstance3D = $core
@onready var _timingAura:MeshInstance3D = $timing_aura
@onready var _shape:CollisionShape3D = $CollisionShape3D

var teamId:int = Game.TEAM_ID_ENEMY
var sourceId:String = ""

var _tick:float = 0.0
var _duration:float = 0.5

func _ready():
	off()

func run(duration:float) -> void:
	#_shape.disabled = false
	call_deferred("_shape_on")
	_duration = duration
	_tick = 0.0
	self.visible = true
	self.set_process(true)
	_refresh(0)

func _refresh(weight:float) -> void:
	var coreScale:Vector3 = Vector3.ZERO.lerp(Vector3.ONE, weight)
	var timingScale:Vector3 = Vector3.ONE.lerp(Vector3.ZERO, weight)
	_core.scale = coreScale
	_timingAura.scale = timingScale
	pass

func hit(hitInfo:HitInfo, _victimNode:Node) -> int:
	if hitInfo.sourceId == sourceId:
		return Game.HIT_RESPONSE_SELF_HIT
	if !Game.is_hit_valid(hitInfo.teamId, teamId):
		return Game.HIT_RESPONSE_TEAM_MATE
	off()
	self.emit_signal("WindUpHit", self, hitInfo, _tick / _duration)
	return hitInfo.damage

func off() -> void:
	#_shape.disabled = true
	call_deferred("_shape_off")
	self.visible = false
	self.set_process(false)

func _shape_on() -> void:
	_shape.disabled = false

func _shape_off() -> void:
	_shape.disabled = true

func _process(delta):
	_tick += delta
	if _tick > _duration:
		_shape.disabled = false
		self.visible = false
		self.set_process(false)
		return
	_refresh(_tick / _duration)
	#_tick += (delta * 4)
	#var s:float = sin(_tick)
	#s += 1
	#s /= 2
	#_refresh(s)
	pass
