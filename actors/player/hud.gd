extends Node

@onready var _tarotLabel:Label = $tarot_status/Label
@onready var _bulletsLabel:Label = $bullets/Label
@onready var _healthLabel:Label = $health/Label
@onready var _superShotPercentage:TextureProgressBar = $bullets/super_shot_percentage

func _ready():
	add_to_group(Game.GROUP_PLAYER_EVENTS)

func player_event_hud_status(status:HudStatus) -> void:
	_tarotLabel.text = status.tarot
	_bulletsLabel.text = str(status.bullets)
	_healthLabel.text = str(status.health)
	var percentage:int = int(status.superShotWeight * 100.0)
	_superShotPercentage.value = percentage
	pass
