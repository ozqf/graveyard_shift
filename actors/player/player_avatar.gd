extends CharacterBody3D

const RUN_SPEED = 7.0
const ACCELERATION_GROUND:float = 250
const ACCELERATION_AIR:float = 25
const JUMP_SPEED:float = 7
const FRICTION_FLOOR:float = 0.8
const MOUSE_RELATIVE_SENSITIVITY:float = 0.003

@onready var _head:PlayerAttack = $body/head
@onready var _playerInput:PlayerInput = $PlayerInput
@onready var _hudStatus:HudStatus = $HudStatus

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _health:float = 100.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(_delta:float) -> void:
	_hudStatus.health = _health
	_head.write_hud_status(_hudStatus)
	var grp:String = Game.GROUP_PLAYER_EVENTS
	var fn:String = Game.FN_PLAYER_EVENT_HUD_STATUS
	get_tree().call_group(grp, fn, _hudStatus)
	pass

func _process(delta):
	if !Game.get_player_input_on():
		return
	
	_playerInput.attack1 = Input.is_action_pressed("attack_1")
	_playerInput.attack2 = Input.is_action_pressed("attack_2")
	_playerInput.style = Input.is_action_pressed("style")
	_head.tick(delta, _playerInput)
	
	var inputDir:Vector3 = Vector3()
	inputDir.x = Input.get_axis("move_left", "move_right")
	inputDir.y = Input.get_axis("move_down", "move_up")
	inputDir.z = Input.get_axis("move_forward", "move_backward")
	
	# horizontal movement (X and Z)
	# translate input axes to axes of object
	# Basis is a 3x3 matrix storing x/y/z orientation vectors.
	# we multiply the forward and left of our current orientation
	# to scale them by the input
	var rot:Basis = global_transform.basis
	var pushDir:Vector3 = Vector3()
	pushDir += inputDir.x * rot.x
	pushDir += inputDir.z * rot.z
	pushDir = pushDir.normalized()
	
	# separate out horizontal component of velocity, calculate it
	# and apply it back. Y is handled independently
	var horizontal:Vector3 = self.velocity
	horizontal.y = 0
	
	# apply friction to slow teh player if required.
	# this is a straight multiply with no delta and thus framerate dependent
	if pushDir == Vector3.ZERO:
		if is_on_floor():
			horizontal = horizontal * FRICTION_FLOOR
	else:
		# apply current input push
		var pushStrength:float = ACCELERATION_GROUND
		if !is_on_floor():
			pushStrength = ACCELERATION_AIR
		horizontal += pushDir * pushStrength * delta
	
	# cap horizontal speed
	horizontal = horizontal.limit_length(RUN_SPEED)
	
	# apply new hoizontal motion back to velocity
	self.velocity.x = horizontal.x
	self.velocity.z = horizontal.z
	
	# vertical
	if is_on_floor():
		if inputDir.y > 0:
			self.velocity.y = JUMP_SPEED
	else:
		# +y is up so gravity strength is negative when applied. 
		self.velocity += Vector3(0, -_gravity, 0) * delta
	
	# do
	move_and_slide()

func _input(event):
	if !Game.get_player_input_on():
		return
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	
	# motion.relative is movement from last cursor position.
	# value is in pixels and thus not resolution dependent!
	# sensitivity will go down as resolution goes up here.
	var yawRadians:float = -motion.relative.x * MOUSE_RELATIVE_SENSITIVITY
	self.rotate(Vector3.UP, yawRadians)
	
	var pitchRadians:float = motion.relative.y * MOUSE_RELATIVE_SENSITIVITY
	_head.rotate(Vector3.RIGHT, pitchRadians)
