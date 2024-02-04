extends Node

var _spatialAudioType = preload("res://services/audio/quick_audio_player_3d.tscn")
var _omniAudioType = preload("res://services/audio/quick_audio_player_3d.tscn")

var _masterBusId:int = -1
var _worldBusId:int = -1
var _ambienceBusId:int = -1
var _uiBusId:int = -1
var _bgmBusId:int = -1

func _ready() -> void:
	_masterBusId = AudioServer.get_bus_index("Master")
	_worldBusId = AudioServer.get_bus_index("world")
	_ambienceBusId = AudioServer.get_bus_index("ambience")
	_uiBusId = AudioServer.get_bus_index("ui")
	_bgmBusId = AudioServer.get_bus_index("bgm")

func _set_bus_volume_percent(busIndex:int, percentage:float) -> void:
	if percentage <= 0:
		AudioServer.set_bus_mute(busIndex, true)
	else:
		AudioServer.set_bus_mute(busIndex, false)
	var level:float = percentage / 100.0
	var maxDb:float = 0
	var minDb:float = -40
	var val:float = minDb * (1 - level) + (maxDb * level)
	AudioServer.set_bus_volume_db(busIndex, val)

func set_volumes(_master:float, sfx:float, bgm:float) -> void:
	_set_bus_volume_percent(_masterBusId, _master)
	_set_bus_volume_percent(_worldBusId, sfx)
	_set_bus_volume_percent(_bgmBusId, bgm)

func _get_omni_source() -> AudioStreamPlayer:
	var source = _omniAudioType.instantiate()
	self.add_child(source)
	return source

func _get_3d_source() -> AudioStreamPlayer3D:
	var source = _spatialAudioType.instantiate()
	self.add_child(source)
	return source

func quick_play_3d(pos:Vector3, _stream:AudioStream, dbOffset:float = 0.0, delay:float = 0.0) -> AudioStreamPlayer3D:
	var source:AudioStreamPlayer3D = _get_3d_source()
	source.global_transform.origin = pos
	source.custom_play(_stream, dbOffset, delay)
	return source

###########################################
# util
###########################################

# sounds
var _sndPistolFire = preload("res://shared/sounds/weapons/pistol_fire.wav")
var _sndSnappyExplosion = preload("res://shared/sounds/explode.wav")
var _sndBulletImpact = preload("res://shared/sounds/Bullet_Impact_4.wav")
var _sndHeadshot = preload("res://shared/sounds/headshot.wav")


func play_pistol_fire(pos:Vector3) -> void:
	quick_play_3d(pos, _sndPistolFire)

func play_snappy_explosion(pos:Vector3) -> void:
	quick_play_3d(pos, _sndSnappyExplosion)

func play_bullet_impact(pos:Vector3) -> void:
	quick_play_3d(pos, _sndBulletImpact)

func play_headshot(pos:Vector3) -> void:
	quick_play_3d(pos, _sndHeadshot)
