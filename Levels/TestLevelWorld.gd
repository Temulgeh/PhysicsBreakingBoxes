extends Node2D


onready var exit_left = $ExitLeft
onready var exit_right = $ExitRight
onready var exit_up = $ExitUp
onready var exit_down = $ExitDown


func _init():
	Global.level = self
