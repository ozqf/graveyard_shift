extends Light3D
class_name ZqfTaggedLight

const GROUP_NAME:String = "zqf_tagged_lights"
# params subGroup:String, queryTag:String, on:bool
const FN_TAGGED_LIGHTS_CHANGE:String = "zqf_tagged_lights_change"

static func broadcast_change(tree:SceneTree, lightsSubGroup:String, queryTag:String, on:bool) -> void:
	tree.call_group(GROUP_NAME, FN_TAGGED_LIGHTS_CHANGE, lightsSubGroup, queryTag, on)

@export var subGroup:String = ""
@export var tag:String = ""

func _ready():
	self.add_to_group(GROUP_NAME)

func zqf_tagged_lights_change(_subGroup:String, queryTag:String, on:bool) -> void:
	if _subGroup != "" && _subGroup != subGroup:
		return
	if queryTag != "" && queryTag != tag:
		return
	self.visible = on
