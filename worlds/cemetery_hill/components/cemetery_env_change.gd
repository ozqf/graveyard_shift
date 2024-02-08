extends WorldEnvironment

@onready var _moonlight:DirectionalLight3D = $moonlight
@onready var _settingSun:DirectionalLight3D = $setting_sun
@onready var _fogVolume:FogVolume = $FogVolume
@onready var _rain:GPUParticles3D = $rain

@export var duskEnvironment:Environment = null
@export var nightEnvironment:Environment = null

func _ready():
	_fogVolume.visible = false
	add_to_group(Game.GROUP_GAME_EVENTS)

func _set_to_night() -> void:
	_fogVolume.visible = false
	_moonlight.visible = true
	_settingSun.visible = false
	environment = nightEnvironment
	_rain.emitting = true
	ZqfTaggedLight.broadcast_change(get_tree(), "lamp_posts", "lamp_post", true)

func _set_to_magic_hour() -> void:
	_fogVolume.visible = false
	_moonlight.visible = false
	_settingSun.visible = true
	environment = duskEnvironment
	_rain.emitting = false
	ZqfTaggedLight.broadcast_change(get_tree(), "lamp_posts", "lamp_post", false)

func game_event_state_change(newState:GameService.GameState, _prevState:GameService.GameState) -> void:
	match newState:
		GameService.GameState.Play:
			_set_to_magic_hour()
		_:
			_set_to_magic_hour()
