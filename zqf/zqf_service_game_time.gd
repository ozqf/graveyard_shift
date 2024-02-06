extends Node
class_name ZqfServiceGameTime

var _effects:Dictionary = {}

func add_effect(newName:String, newTimeScale:float, newDurationSeconds:float) -> void:
	if newName == null || newName == "":
		return
	if newTimeScale <= 0.0 || newTimeScale > 1.0:
		return
	if newDurationSeconds < 0.0:
		return
	
	if _effects.has(newName):
		var effect = _effects[newName]
		effect.timeScale = newTimeScale
		effect.duration = newDurationSeconds
		return
	_effects[newName] = {
		"timeScale" = newTimeScale,
		"duration" = newDurationSeconds
	}

func remove_effect(newName:String) -> void:
	if !_effects.has(newName):
		return
	_effects.erase(newName)

func _refresh() -> void:
	if _effects.is_empty():
		Engine.time_scale = 1.0
	var lowestScale:float = 1.0
	for key in _effects:
		var effect:Dictionary = _effects[key]
		if effect.timeScale < lowestScale:
			lowestScale = effect.timeScale
	Engine.time_scale = lowestScale

func _decrement_effects(_delta) -> void:
	if _effects.is_empty():
		return
	
	var keys = _effects.keys()
	for key in keys:
		var effect:Dictionary = _effects[key]
		effect.duration -= _delta
		if effect.duration <= 0.0:
			_effects.erase(key)

func _calc_scaled_delta(_delta) -> float:
	var timeScale = Engine.time_scale
	if timeScale > 0.0 && timeScale < 1.0:
		_delta *= (1.0 / timeScale)
	return _delta
	
func _process(_delta:float) -> void:
	_delta = _calc_scaled_delta(_delta)
	_decrement_effects(_delta)
	_refresh()
