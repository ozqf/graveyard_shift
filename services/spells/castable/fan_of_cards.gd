extends Node

var _prjThrownCard = preload("res://projectiles/thrown_card/prj_thrown_card.tscn")

func attach(__userInfo:SpellUserInfo) -> void:
	pass

func cast(__userInfo:SpellUserInfo) -> void:
	print("Fan of cards cast")
	var prj = _prjThrownCard.instantiate()
	Game.get_actor_root().add_child(prj)
	var info:ProjectileLaunchInfo = prj.get_launch_info()
	var t:Transform3D = __userInfo.leftHand.global_transform
	info.origin = t.origin
	info.forward = -t.basis.z
	info.teamId = Game.TEAM_ID_PLAYER
	info.sourceId = __userInfo.sourceId
	prj.launch()

