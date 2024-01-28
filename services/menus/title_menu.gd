extends Node

@onready var _start:ZqfButton = $ZqfButton
# Called when the node enters the scene tree for the first time.
func _ready():
	_start.connect("custom_pressed", _on_button_pressed)

func _enter_tree():
	Game.add_mouse_claim(self)

func _exit_tree():
	Game.remove_mouse_claim(self)

func _on_button_pressed(_button) -> void:
	Game.goto_start_game()
