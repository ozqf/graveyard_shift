extends Node3D

@export var hideOnStart:bool = true
@export var hideParent:bool = false

func _ready() -> void:
	var flag:bool = !hideOnStart
	if hideParent:
		get_parent().visible = flag
	else:
		self.visible = flag
