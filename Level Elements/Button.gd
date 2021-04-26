extends Area2D


func get_class():
	return "Button"


func is_active():
	if get_overlapping_bodies():
		return true
	return false
