extends Node
class_name MobThinkInfo

var hasTarget:bool = false
var targetInfo:TargetInfo

var footTransform:Transform3D
var headTransform:Transform3D

var distToTargetSqrTrue:float = 0
var distToTargetSqrFlat:float = 0
var hasLineOfSight:bool = false
