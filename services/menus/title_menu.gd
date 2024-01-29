extends Node

@onready var _start:ZqfButton = $start
@onready var _exit:ZqfButton = $exit

func _ready():
	_start.connect("custom_pressed", _on_button_pressed)
	_exit.connect("custom_pressed", _on_button_pressed)

func _enter_tree():
	Game.add_mouse_claim(self)

func _exit_tree():
	Game.remove_mouse_claim(self)

func _on_button_pressed(_button) -> void:
	if _button == _start:
		Game.goto_start_game()
	elif _button == _exit:
		Game.exit_to_desktop()
