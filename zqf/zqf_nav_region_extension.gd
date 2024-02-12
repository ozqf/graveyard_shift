extends NavigationRegion3D
class_name ZqfNavRegionExtension

const GROUP_NAME:String = "nav_region_builder_group"
const FN_NAV_MESH_UPDATE:String = "nav_mesh_update"

@export var buildOnReady:bool = true
var _dirty:bool = false

func _ready() -> void:
	if buildOnReady:
		_dirty = true

func nav_mesh_update() -> void:
	_dirty = true

func _process(_delta:float) -> void:
	if _dirty:
		_dirty = false
		bake_navigation_mesh()
