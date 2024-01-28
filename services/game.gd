extends Node3D

# any positive number is damage inflicted
const HIT_RESPONSE_DAMAGE_DONE:int = 1
# yes you hit me, but did no damage
const HIT_RESPONSE_WHIFF:int = 0
# you hit, and should just vanish.
const HIT_RESPONSE_ABSORB:int = -1

const TEAM_ID_FREE_AGENT:int = 0
const TEAM_ID_ENEMY:int = 1
const TEAM_ID_PLAYER:int = 2
const TEAM_ID_NONE_COMBATANT:int = 3

enum GameState {
	Startup,
	Title,
	Pregame,
	Game,
	Postgame
}

# worlds
var _sandboxScene = preload("res://worlds/sandbox/sandbox.tscn")
var _titleScene = preload("res://worlds/title/title.tscn")

# gfx
var _impactBulletWall = preload("res://gfx/impacts/gfx_impact_bullet_wall.tscn")

@onready var _worldRoot:Node3D = $world
@onready var _mainMenu:PauseMenu = $PauseMenu

var _playerInputOn:bool = false
var _gameState:GameState = GameState.Startup

func _ready():
	var world = _sandboxScene.instantiate()
	#var world = _titleScene.instantiate()
	_worldRoot.add_child(world)
	
	_playerInputOn = true
	_mainMenu.set_on(false)

func _process(delta):
	pass

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		# toggle menu
		if _mainMenu.get_on():
			_playerInputOn = true
			_mainMenu.set_on(false)
		else:
			_playerInputOn = false
			_mainMenu.set_on(true)
		pass

func set_player_input_on(flag:bool) -> void:
	_playerInputOn = flag
	if _playerInputOn:
		remove_mouse_claim(self)
	else:
		add_mouse_claim(self)

func get_player_input_on() -> bool:
	return _playerInputOn

func get_actor_root() -> Node3D:
	return _worldRoot

###################################################################
# Game State
###################################################################

func goto_title() -> void:
	pass

func goto_start_game() -> void:
	pass

###################################################################
# Mouse claims
###################################################################
var _mouseClaims:Array = []

func _refresh_mouse_claims() -> void:
	if _mouseClaims.size() > 0:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func has_mouse_claims() -> bool:
	return _mouseClaims.size() > 0

func add_mouse_claim(claimant:Node) -> void:
	var i:int = _mouseClaims.find(claimant)
	if i == -1:
		_mouseClaims.push_back(claimant)
	_refresh_mouse_claims()

func remove_mouse_claim(claimant:Node) -> void:
	var i:int = _mouseClaims.find(claimant)
	if i >= 0:
		_mouseClaims.remove_at(i)
	_refresh_mouse_claims()

###################################################################
# interactions
###################################################################

func is_hit_valid(attackerTeam:int, defenderTeam:int) -> bool:
	if defenderTeam == TEAM_ID_NONE_COMBATANT:
		return false
	if attackerTeam == TEAM_ID_FREE_AGENT || defenderTeam == TEAM_ID_FREE_AGENT:
		return true
	if attackerTeam != defenderTeam:
		return true
	return false

func try_hit(victim, _hitInfo:HitInfo) -> int:
	if victim.has_method("hit"):
		return victim.hit(_hitInfo)
	return HIT_RESPONSE_WHIFF

###################################################################
# gfx
###################################################################
func gfx_spawn_bullet_wall_impact(pos:Vector3, forward:Vector3) -> Node3D:
	var gfx:Node3D = _impactBulletWall.instantiate()
	_worldRoot.add_child(gfx)
	gfx.global_position = pos
	ZqfUtils.look_at_safe(gfx, pos + forward)
	return gfx
