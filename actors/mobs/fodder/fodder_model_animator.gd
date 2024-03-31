extends MobModelAnimator

@onready var _neck:Node3D = $torso/neck

func play_idle() -> void:
	_neck.rotation_degrees = Vector3(-45, 0, 0)
	pass

func play_aiming() -> void:
	_neck.rotation_degrees = Vector3(0, 0, 0)
	pass

func refresh() -> void:
	if _baseState == MobBase.MobBaseState.Hunting:
		if _huntState == MobBase.MobHuntState.Action || _huntState == MobBase.MobHuntState.WindUp:
			play_aiming()
			return
	play_idle()
