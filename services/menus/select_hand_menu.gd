extends Node

@onready var _play:ZqfButton = $play

func _ready() -> void:
	_play.connect("custom_pressed", _on_play)

func _on_play(_button) -> void:
	Game.goto_playing()
