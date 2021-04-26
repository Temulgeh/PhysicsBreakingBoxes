extends ViewportContainer


onready var viewport = $Viewport


func set_world(world):
	viewport.world_2d = world


func change_scale(scale: float):
	rect_scale = Vector2(scale, scale)


func change_position(position):
	rect_position = position
