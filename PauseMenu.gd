extends Node2D


var paused = false

onready var music = $AudioStreamPlayer


func _input(event):
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	if event.is_action_pressed("ui_home"):
		if paused:
			paused = false
			get_tree().paused = false
			visible = false
		else:
			paused = true
			get_tree().paused = true
			visible = true
	if event.is_action_pressed("reset"):
		Global.emit_signal("reset")
#	if event.is_action_pressed("true_reset"):
#		get_tree().reload_current_scene()


func _ready():
	music.play()
	visible = false
