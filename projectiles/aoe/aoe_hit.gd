extends Area3D
class_name AOE

@onready var _hitInfo:HitInfo = $HitInfo

var _ticks:int = 0

func get_hit_info() -> HitInfo:
	return _hitInfo

func _run_hits() -> void:
	var areas = get_overlapping_areas()
	print("AOE hits: " + str(areas.size()))
	for area in areas:
		Game.try_hit(area, _hitInfo)
		pass
	pass

func _process_old(_delta):
	_ticks += 1
	if get_overlapping_areas().size() > 0:
		_run_hits()

func _physics_process(_delta:float) -> void:
	_ticks += 1
	if _ticks == 2:
		self.queue_free()
		_run_hits()
	#elif _ticks == 1000:
	#	self.queue_free()
