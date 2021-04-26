extends KinematicBody2D


var animation_timer: int

export var direction: Vector2


func get_class():
	return "Exit"


#func get_exit_position():
#	return position - direction * Global.TILESIZE


func move(direction, invert_dir = false):
	animation_timer = Global.ANIMATION_TIME
	Global.lock_movement = self
	return Global.recursive_box


func _physics_process(delta):
	if animation_timer:
		animation_timer -= 1
		if animation_timer == 0:
			if Global.lock_movement == self:
				Global.lock_movement = null
