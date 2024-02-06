extends MobBase

var _prjEnemyBullet = preload("res://projectiles/enemy_bullet/prj_enemy_bullet.tscn")

@onready var _attackSource:RayCast3D = $model/attack_source
@onready var _shotWindUp = $model/attack_source/ShotWindUp

func _ready() -> void:
	super._ready()
	_health = 40
	_shotWindUp.connect("WindUpHit", _on_windup_hit)
	_shotWindUp.sourceId = uuid

func receive_taunt() -> void:
	print("Mob taunted!")
	if !_baseState == MobBase.MobBaseState.Hunting:
		return
	if _huntState != MobHuntState.WindUp:
		return
	_huntState = MobBase.MobHuntState.WindUp
	print("Mob fuming!")
	_shotWindUp.run(0.5)

func _detonate_gun() -> void:
	var aoe:AOE = Game.spawn_aoe(_attackSource.global_position)
	aoe.get_hit_info().damage = 100
	aoe.get_hit_info().teamId = Game.TEAM_ID_PLAYER
	#aoe.scale = Vector3(12, 12, 12)

func _on_windup_hit(_windUpInstance, _attack:HitInfo, _weight:float) -> void:
	if _huntState == MobBase.MobHuntState.WindUp:
		print("Interupt weight " + str(_weight))
		var popGfx:Node3D = Game.gfx_spawn_quickdraw_cancel(_windUpInstance.global_position)
		_huntState = MobBase.MobHuntState.WindDown
		_mobBaseThinkTimer.start(1.0)
		_detonate_gun()
		if _weight >= 0.75:
			GameAudio.play_snappy_explosion(_attackSource.global_position)
			if _attack.isQuickShot:
				GameAudio.play_headshot(_attackSource.global_position)
				popGfx.scale = Vector3(3, 3, 3)
				#_detonate_gun()
			else:
				popGfx.scale = Vector3(2, 2, 2)
			Game.gfx_spawn_pop_blood_impact(_windUpInstance.global_position, _windUpInstance.global_transform.basis.x)
			die()

func _fire_bullet(origin:Node3D) -> void:
	GameAudio.play_pistol_fire(origin.global_position)
	var prj = _prjEnemyBullet.instantiate()
	Game.get_actor_root().add_child(prj)
	var info:ProjectileLaunchInfo = prj.get_launch_info()
	info.sourceId = uuid
	info.teamId = Game.TEAM_ID_ENEMY
	info.origin = origin.global_position
	info.forward = -origin.global_transform.basis.z
	prj.launch()

func _tick_hunt(_delta:float) -> void:
	match _huntState:
		MobBase.MobHuntState.Chase:
			_look_toward_flat(_thinkInfo.targetInfo.footPosition)
			_update_targeting_ray(_attackSource, _thinkInfo.targetInfo.headPosition)

			if !_thinkInfo.hasLineOfSight || _thinkInfo.distToTargetSqrFlat > (20 * 20):
				_approach_move_target(_delta)
		
		MobBase.MobHuntState.WindUp:
			_look_toward_flat(_thinkInfo.targetInfo.footPosition)
			_update_targeting_ray(_attackSource, _thinkInfo.targetInfo.headPosition)
	pass

func _tock_hunt() -> void:
	match _huntState:
		MobBase.MobHuntState.Chase:
			var thinkTime:float = 0.25
			if !_attackSource.is_colliding():
				# begin windup
				_huntState = MobBase.MobHuntState.WindUp
				thinkTime = 0.5
				_shotWindUp.run(thinkTime)
			_mobBaseThinkTimer.start(thinkTime)
		MobBase.MobHuntState.WindUp:
			# perform action
			_fire_bullet(_attackSource)
			_huntState = MobBase.MobHuntState.Action
			_mobBaseThinkTimer.start(0.5)
		MobBase.MobHuntState.Action:
			# completed action, enter recovery
			_huntState = MobBase.MobHuntState.WindDown
			_mobBaseThinkTimer.start(0.5)
		MobBase.MobHuntState.WindDown:
			_mobBaseThinkTimer.start(1.0)
			_huntState = MobBase.MobHuntState.Chase
