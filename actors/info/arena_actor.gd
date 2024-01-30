extends Node

var _fodderType = preload("res://actors/mobs/fodder/mob_fodder.tscn")

var _spawnNodes = []

var _activeMobs:Dictionary = {}

func _ready():
	add_to_group(Game.GROUP_NAME_ARENAS)

func start() -> void:
	_spawnNodes = self.get_children()
	var i:int = 10

	while i > 0:
		var node = _spawnNodes[i % _spawnNodes.size()]
		i -= 1

		var mob = _fodderType.instantiate()
		Game.get_actor_root().add_child(mob)
		mob.global_transform = node.global_transform
		var info:MobLaunchInfo = mob.get_launch_info()
		info.tag = UUID.v4()
		_activeMobs[info.tag] = mob
