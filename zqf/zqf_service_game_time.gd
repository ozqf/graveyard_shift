extends Node
class_name ZqfServiceGameTime

var _seconds:float = 0.0

func run(_scale:float, durationSeconds:float) -> void:
	print("Slowmo " + str(_scale) + " for " + str(durationSeconds))
	Engine.time_scale = _scale
	_seconds = durationSeconds

func _process(_delta:float) -> void:
	if _seconds <= 0.0:
		return
	var timeScale = Engine.time_scale
	var mul:float = 1
	if timeScale == 1.0:
		_seconds -= _delta
	elif timeScale <= 0.0:
		_seconds -= _delta
	elif timeScale <= 1.0:
		_delta *= (1.0 / timeScale)
		_seconds -= _delta
	if _seconds <= 0.0:
		Engine.time_scale = 1.0
