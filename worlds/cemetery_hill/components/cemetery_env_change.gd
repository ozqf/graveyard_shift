extends WorldEnvironment

@onready var _moonlight:DirectionalLight3D = $moonlight
@onready var _settingSun:DirectionalLight3D = $setting_sun
@onready var _fogVolume:FogVolume = $FogVolume

@export var duskEnvironment:Environment = null
@export var nightEnvironment:Environment = null

func _ready():
	_fogVolume.visible = false
	add_to_group(Game.GROUP_GAME_EVENTS)

func game_event_state_change(newState:Gam.GameState, prevState:Gam.GameState) -> void:
	match newState:
		Gam.GameState.Play:
			_fogVolume.visible = true
			_moonlight.visible = true
			_settingSun.visible = false
			
			environment = nightEnvironment
		_:
			_fogVolume.visible = false
			_moonlight.visible = true
			_settingSun.visible = false
			environment = duskEnvironment
