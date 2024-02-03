extends RayCast3D
class_name MobAttackSource

func update_target(target:Vector3) -> void:
	ZqfUtils.look_at_safe(self, target)
	var dist:float = self.global_position.distance_to(target)
	self.target_position = Vector3(0, 0, -dist)
	pass
