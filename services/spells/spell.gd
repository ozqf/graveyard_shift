extends Node
class_name Spell

var _spellType:String = "sharp_cards"

func set_spell_type(newType:String) -> void:
	_spellType = newType

func cast() -> void:
	print(self.name + " cast")
	pass
