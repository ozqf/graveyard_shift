extends Control
class_name PauseMenu

@onready var _backToGame:ZqfButton = $back_to_game
@onready var _toSettings:ZqfButton = $to_settings
@onready var _backToTitle:ZqfButton = $back_to_title

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

func _ready():
	_backToGame.connect("custom_pressed", _on_button_pressed)
	_toSettings.connect("custom_pressed", _on_button_pressed)
	_backToTitle.connect("custom_pressed", _on_button_pressed)

func _on_button_pressed(_button) -> void:
	if _button == _backToGame:
		Game.resume_game()
	elif _button == _toSettings:
		pass
	elif _button == _backToTitle:
		Game.goto_title()
	pass
