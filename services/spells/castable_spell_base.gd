extends Node
class_name CastableSpellBase

var _totalCharges:int = 1
var _charges:int = 1
var _tick:float = 0.0

func attach(__userInfo:SpellUserInfo) -> void:
	pass

func cast(__userInfo:SpellUserInfo) -> void:
	print(self.name + " cast")
	pass
