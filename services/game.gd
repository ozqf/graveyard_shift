extends Node

# worlds
var _sandboxScene = preload("res://worlds/sandbox/sandbox.tscn")

# gfx
var _impactBulletWall = preload("res://gfx/impacts/gfx_impact_bullet_wall.tscn")

@onready var _worldRoot:Node3D = $world
@onready var _mainMenu:MainMenu = $main_menu

var _playerInputOn:bool = false

func _ready():
	var world = _sandboxScene.instantiate()
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
# gfx
###################################################################
func gfx_spawn_bullet_wall_impact(pos:Vector3, forward:Vector3) -> Node3D:
	var gfx:Node3D = _impactBulletWall.instantiate()
	_worldRoot.add_child(gfx)
	gfx.global_position = pos
	ZqfUtils.look_at_safe(gfx, pos + forward)
	return gfx
