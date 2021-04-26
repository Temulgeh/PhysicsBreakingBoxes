extends Node2D


var buttons = []

onready var level10_map = get_node("../Level10/TileMap")
onready var level11_map = get_node("../Level11/TileMap")
onready var level12_map = get_node("../Level12/TileMap")
onready var level13_map = get_node("../Level13/TileMap")
onready var you_done_it = get_node("../YouDoneIt")


func _ready():
	visible = true
	search_buttons(self)
	Global.connect("move_ended", self, "check")


func search_buttons(node):
	for child in node.get_children():
		if child.get_class() == "Button":
			buttons.append(child)
		search_buttons(child)


func check():
	var level_done = true
	for button in buttons:
		if not button.is_active():
			level_done = false
	if level_done:
		Global.camera.shake()
		Global.emit_signal("set_default_pos")
		# probably a terrible way to do it, but i have 2 hours left
		Global.level_id += 1
		print(Global.level_id)
		if Global.level_id == 6:
			Global.recursive_box.custom_move(Vector2(72, 152))
		elif Global.level_id == 10:
			level10_map.position = Vector2.ZERO
		elif Global.level_id == 11:
			level11_map.position = Vector2.ZERO
		elif Global.level_id == 12:
			level12_map.position = Vector2.ZERO
			print(12)
		elif Global.level_id == 13:
			level13_map.position = Vector2.ZERO
		elif Global.level_id == 14:
			you_done_it.visible = true
		queue_free()
