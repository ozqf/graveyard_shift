extends CastableSpellBase

func hud_name() -> String:
	return "Bullet Time"

func cast(__userInfo:SpellUserInfo) -> void:
	print("Cast Bullet time")
	GameTime.add_effect("card_bullet_time", 0.2, 4.0)
