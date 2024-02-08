extends RayCast3D

@onready var hitInfo:HitInfo = $HitInfo

var ricochets:int = 0
var ticks:int = 0

func _physics_process(_delta:float) -> void:
	ticks += 1
	if ticks >= 120:
		self.queue_free()
		ticks = 0
