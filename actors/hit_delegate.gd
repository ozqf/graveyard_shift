extends Node

var subject = null

func hit(_info, _victimNode:Node) -> int:
	if subject != null:
		return subject.hit(_info, _victimNode)
	return get_parent().hit(_info, _victimNode)
