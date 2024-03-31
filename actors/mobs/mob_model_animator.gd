extends Node
class_name MobModelAnimator

#signal MobBaseStateChanged(newMobState:MobBaseState)
#signal MobHuntStateChanged(newHuntState:MobHuntState)
var _baseState:MobBase.MobBaseState = MobBase.MobBaseState.Idle
var _huntState:MobBase.MobHuntState = MobBase.MobHuntState.Chase

func _ready() -> void:
	var node:Node = get_parent()
	node.connect("MobBaseStateChanged", _on_mob_base_state_changed)
	node.connect("MobHuntStateChanged", _on_mob_hunt_state_changed)

func _on_mob_base_state_changed(newMobState:MobBase.MobBaseState) -> void:
	_baseState = newMobState
	refresh()

func _on_mob_hunt_state_changed(newHuntState:MobBase.MobHuntState) -> void:
	_huntState = newHuntState
	refresh()

func refresh() -> void:
	pass
