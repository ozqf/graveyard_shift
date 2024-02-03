extends MobBase

@onready var _attackSource:RayCast3D = $model/attack_source

func _ready() -> void:
	super._ready()
	_health = 30

func _tick_hunt(_delta:float) -> void:
	_look_toward_flat(_thinkInfo.targetInfo.footPosition)
	_update_targeting_ray(_attackSource, _thinkInfo.targetInfo.headPosition)
	_approach_move_target(_delta)
	pass

func _tock_hunt() -> void:
	_mobBaseThinkTimer.start(0.5)
	_mobBaseThinkTimer.paused = false
	if !_attackSource.is_colliding():
		print("Mob can see player")
	else:
		print("Mob cannot see player")
