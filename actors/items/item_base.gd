extends PhysicsBody3D

@export var itemType:String = ""
@export var amount:float = 1.0

func _ready() -> void:
	self.linear_velocity = Vector3(0, 3, 0)

func is_item_base() -> void:
	pass

func took_item(amountTaken:float) -> void:
	if amountTaken > 0.0:
		self.queue_free()
