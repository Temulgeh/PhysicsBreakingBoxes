extends Node


signal reset
signal move_ended
signal set_default_pos


const TILESIZE = 16
const MAIN_BOX_SIZE = 288
const ANIMATION_TIME = 10


var lock_movement: Node
var level_id = 1

var camera: Camera2D
var viewport_size: Vector2
var level_container: Node2D
var recursive_box: KinematicBody2D
var world: World2D
var level: Node2D


func _init():
	viewport_size = OS.window_size
	OS.window_size *= 2
	OS.center_window()


func _ready():
	pass
