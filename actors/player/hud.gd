extends Node

@onready var _tarotLabel:Label = $tarot_status/Label
@onready var _bulletsLabel:Label = $bullets/Label
@onready var _healthLabel:Label = $health/Label

func _ready():
	add_to_group(Game.GROUP_PLAYER_EVENTS)

func player_event_hud_status(status:HudStatus) -> void:
	_tarotLabel.text = status.tarot
	_bulletsLabel.text = str(status.bullets)
	_healthLabel.text = str(status.health)
	pass
