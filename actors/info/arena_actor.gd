extends Node

var _fodderType = preload("res://actors/mobs/fodder/mob_fodder.tscn")

@onready var _timer:Timer = $Timer
@onready var _spawnPoints:Node3D = $spawn_points

var _spawnNodes = []
var _spawnIndex:int = 0
var _activeMobs:Dictionary = {}
var _maxActive:int = 10

func _ready():
	set_physics_process(false)
	self.visible = false
	add_to_group(Game.GROUP_NAME_ARENAS)
	add_to_group(Game.GROUP_GAME_EVENTS)

func game_event_mob_died(_mob, _tag:String) -> void:
	if !_activeMobs.has(_tag):
		#print("Mob death not of interest to arena")
		return
	
	_activeMobs.erase(_tag)
	var s:int = _activeMobs.size()
	#print("Arena has " + str(s) + " mobs active")
	pass

func _physics_process(_delta:float) -> void:
	if _timer.time_left != 0.0:
		return
	if _activeMobs.size() < _maxActive:
		_timer.start(3.0)
		_timer.paused = false
		_spawn_mob()

func _spawn_mob() -> void:
	var numNodes:int = _spawnNodes.size()
	var spawnTransform:Transform3D
	if numNodes > 0:
		var node = _spawnNodes[_spawnIndex % numNodes]
		_spawnIndex += 1
		spawnTransform = node.global_transform
	else:
		spawnTransform = self.global_transform
	
	var mob = _fodderType.instantiate()
	Game.get_actor_root().add_child(mob)
	mob.global_transform = spawnTransform
	var info:MobLaunchInfo = mob.get_launch_info()
	info.tag = UUID.v4()
	_activeMobs[info.tag] = mob
	#print("active mobs " + str(_activeMobs.size()))

func start() -> void:
	# TODO: cannnot use all children, would include point widget and Timer node too
	_spawnNodes = _spawnPoints.get_children()
	set_physics_process(true)
	
