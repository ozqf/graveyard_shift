extends Node

var subject = null

func hit(_info) -> int:
	if subject != null:
		return subject.hit(_info)
	return get_parent().hit(_info)
