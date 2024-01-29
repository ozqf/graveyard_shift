extends Node

@export var groupName:String = ""

func _ready() -> void:
	self.visible = false
	if groupName != null && groupName != "":
		add_to_group(groupName)
