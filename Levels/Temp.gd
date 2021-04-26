extends ViewportContainer


onready var viewport = $Viewport
onready var other = get_node("../Main/Viewport")


func _ready():
	print(other)
	viewport.world_2d = other.world_2d
