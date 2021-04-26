extends TileMap


func _ready():
	material.set_shader_param("screen_resolution", Global.viewport_size)
