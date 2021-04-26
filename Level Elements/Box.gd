extends KinematicBody2D


var previous_position: Vector2
var real_position: Vector2
var animation_timer: int
var default_position: Vector2

onready var sprite = $Sprite


func interpolation(a, b, t):
	var one_minus_t = 1 - t
	return a + (b - a) * (1 - one_minus_t * one_minus_t * one_minus_t)


func teleport(movement):
	animation_timer = 0
	real_position -= movement
	position = real_position
	previous_position = position


func collide(direction, test_position):
	var tmp_collision_layer = collision_layer
	collision_layer = 0
	var collided = false
	var tmp_position = position
	position = test_position
	var collision = move_and_collide(direction * Global.TILESIZE, true, true, true)
	if collision:
		if collision.collider.has_method("move"):
			collided = collision.collider.move(direction, false)
		else:
			collided = true
	position = tmp_position
	collision_layer = tmp_collision_layer
	return collided


func set_default_pos():
	default_position = real_position


func move(direction, invert_dir = false):
	var direction_multiplier = (-int(invert_dir) + .5) * 2
	direction *= direction_multiplier
	var collided = false
	if not invert_dir:
		collided = collide(direction, real_position)
		previous_position = real_position
	else:
		previous_position = position
	if not collided:
		if not invert_dir:
			MoveLogger.add_action_to_move(self, direction)
		real_position += direction * Global.TILESIZE
	elif collided is Node:
		collision_mask &= ~2
		var collided2 = collide(direction, collided.position)
		if not collided2:
			visible = false
			var new_position = collided.position + direction * Global.TILESIZE
			# For some unknown reason when the player reaches an exit it
			# returns "RecursiveBox" and when the player reaches the
			# recursive box it returns "Exit"
			if collided.get_class() == "RecursiveBox":
				Global.level_container.to_big(sprite, direction)
			elif collided.get_class() == "Exit":
				Global.level_container.to_small(sprite, direction)
			if not invert_dir:
				MoveLogger.add_action_to_move(
					self, direction,
					new_position - real_position - direction * Global.TILESIZE
				)
			real_position = new_position
		collision_mask |= 2
	animation_timer = Global.ANIMATION_TIME
	return collided is bool and collided == true


func _ready():
	default_position = position
	previous_position = position
	real_position = position
	Global.connect("reset", self, "reset")
	Global.connect("set_default_pos", self, "set_default_pos")


func reset():
	real_position = default_position
	previous_position = position
	animation_timer = Global.ANIMATION_TIME


func _physics_process(delta):
	if animation_timer:
		animation_timer -= 1
		position = interpolation(
			previous_position,
			real_position,
			1.0 - float(animation_timer) / Global.ANIMATION_TIME
		)
		if animation_timer == 0:
			if not visible:
				visible = true
