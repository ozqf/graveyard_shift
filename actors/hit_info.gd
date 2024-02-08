extends Node
class_name HitInfo

var damage:int = 10
var damageType:int = 0
var teamId:int = 0
var sourceId:String = ""
var isQuickShot:bool = false

var position:Vector3 = Vector3()
var direction:Vector3 = Vector3()

func copy_from(other:HitInfo) -> void:
    damage = other.damage
    damageType = other.damageType
    teamId = other.teamId
    sourceId = other.sourceId
    isQuickShot = other.isQuickShot
    position = other.position
    direction = other.direction
