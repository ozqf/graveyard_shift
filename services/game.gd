extends Node3D
class_name Gam

const GROUP_PLAYER_ACTORS:String = "player_actors"

const GROUP_PLAYER_EVENTS:String = "player_events"
# params: status:HudStatus
const FN_PLAYER_EVENT_HUD_STATUS:String = "player_event_hud_status"

const GROUP_GAME_EVENTS:String = "game_events"
# params: newState:GameState, prevState:GameState
const FN_GAME_EVENT_STATE_CHANGE:String = "game_event_state_change"
# params: mob:Node, tag:String
const FN_GAME_EVENT_MOB_DIED:String = "game_event_mob_died"

const GROUP_NAME_CARD_TABLE_SPAWNS:String = "card_table_spawns"

const GROUP_NAME_ARENAS:String = "arenas"

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
	Play,
	Postgame
}

# worlds
var _cemeteryHillScene = preload("res://worlds/cemetery_hill/cemetery_hill.tscn")
var _titleScene = preload("res://worlds/title/title.tscn")

# gfx
var _impactBulletWall = preload("res://gfx/impacts/gfx_impact_bullet_wall.tscn")
var _impactBulletBlood = preload("res://gfx/impacts/gfx_impact_bullet_blood.tscn")

var _cardTableScene = preload("res://actors/interactive/card_table.tscn")

@onready var _worldRoot:Node3D = $world
@onready var _pauseMenu:PauseMenu = $PauseMenu
@onready var _selectHandMenu = $SelectHandMenu
@onready var _emptyTargetInfo:TargetInfo = $empty_target_info

var _playerInputOn:bool = false
var _gameState:GameState = GameState.Startup

func _ready():
	Engine.max_fps = 120
	goto_title()
	
	_playerInputOn = true
	_pauseMenu.set_on(false)

func _physics_process(_delta):
	var pausableState:bool = true
	if _gameState == GameState.Startup:
		pausableState = false
	if _gameState == GameState.Title:
		pausableState = false
	
	if pausableState && Input.is_action_just_pressed("ui_cancel"):
		# toggle menu
		if _pauseMenu.get_on():
			_playerInputOn = true
			_pauseMenu.set_on(false)
		else:
			_playerInputOn = false
			_pauseMenu.set_on(true)
		pass

func set_player_input_on(flag:bool) -> void:
	_playerInputOn = flag
	if _playerInputOn:
		remove_mouse_claim(self)
	else:
		add_mouse_claim(self)

func get_player_input_on() -> bool:
	return !has_mouse_claims()
	#return _playerInputOn && _gameState == GameState.Play

func get_actor_root() -> Node3D:
	return _worldRoot

func remove_current_world() -> void:
	for child in _worldRoot.get_children():
		child.queue_free()

###################################################################
# Game State
###################################################################

func change_state(newState:GameState) -> void:
	var prevState:GameState = _gameState
	_gameState = newState

	var grp:String = GROUP_GAME_EVENTS
	var fn:String = FN_GAME_EVENT_STATE_CHANGE
	get_tree().call_group(grp, fn, _gameState, prevState)

func goto_title() -> void:
	change_state(GameState.Title)
	remove_current_world()
	_pauseMenu.set_on(false)
	_selectHandMenu.visible = false
	var world = _titleScene.instantiate()
	_worldRoot.add_child(world)

func goto_start_game() -> void:
	change_state(GameState.Pregame)
	_playerInputOn = true
	remove_current_world()
	_selectHandMenu.visible = false
	var world = _cemeteryHillScene.instantiate()
	_worldRoot.add_child(world)

	_place_new_card_table()

func goto_select_hand() -> void:
	_selectHandMenu.on()

func goto_playing() -> void:
	_selectHandMenu.visible = false
	change_state(GameState.Play)
	start_next_arena()

func _place_new_card_table() -> void:
	var pos:Vector3 = Vector3()
	var tablePoints = get_tree().get_nodes_in_group(GROUP_NAME_CARD_TABLE_SPAWNS)
	if tablePoints.size() > 0:
		pos = tablePoints[0].global_position

	var table = _cardTableScene.instantiate()
	_worldRoot.add_child(table)
	table.global_position = pos

func start_next_arena() -> void:
	var arenas = get_tree().get_nodes_in_group(GROUP_NAME_ARENAS)
	if arenas.size() == 0:
		print("Eek - no arenas found")
		return
	arenas[0].start()
	pass

func arena_finished() -> void:
	_place_new_card_table()

func resume_game() -> void:
	_playerInputOn = true
	_pauseMenu.set_on(false)

func exit_to_desktop() -> void:
	get_tree().quit()

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

func get_player_target() -> TargetInfo:
	var node = get_tree().get_first_node_in_group(Game.GROUP_PLAYER_ACTORS)
	if node == null:
		return _emptyTargetInfo
	return node.get_target_info() as TargetInfo

###################################################################
# gfx
###################################################################

func _spawn_gfx(prefabType, pos:Vector3, forward:Vector3) -> Node3D:
	var gfx:Node3D = prefabType.instantiate()
	_worldRoot.add_child(gfx)
	gfx.global_position = pos
	ZqfUtils.look_at_safe(gfx, pos + forward)
	return gfx

func gfx_spawn_bullet_wall_impact(pos:Vector3, forward:Vector3) -> Node3D:
	return _spawn_gfx(_impactBulletWall, pos, forward)

func gfx_spawn_bullet_blood_impact(pos:Vector3, forward:Vector3) -> Node3D:
	return _spawn_gfx(_impactBulletBlood, pos, forward)
