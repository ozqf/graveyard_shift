extends Node

@onready var _play:ZqfButton = $play

func _ready() -> void:
	_play.connect("custom_pressed", _on_play)

func on() -> void:
	Game.add_mouse_claim(self)
	self.visible = true

func off() -> void:
	self.visible = false

func _on_play(_button) -> void:
	Game.remove_mouse_claim(self)
	Game.goto_playing()
	off()
