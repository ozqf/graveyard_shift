extends Control
class_name PauseMenu

var _on:bool = false

func get_on() -> bool:
	return _on

func set_on(flag:bool) -> void:
	_on = flag
	visible = flag
	if _on:
		Game.add_mouse_claim(self)
	else:
		Game.remove_mouse_claim(self)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
