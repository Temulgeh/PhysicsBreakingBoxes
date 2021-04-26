extends KinematicBody2D


# Fix input: hold while going diagonally
# Tiles: make a 3x3 (minimal) tileset in black and white, and use the shader
# to determine the colour


const EYES_BIG_OFFSET = Vector2(2, 3)
const EYES_SMALL_OFFSET = Vector2(1, 1)
const EYES_TIME = 200
const EYES_SMALL_OFFSET_THRESHOLD = 190


onready var parent = get_parent()

var previous_position: Vector2
var real_position: Vector2
var animation_timer: int
var direction: Vector2
var facing: Vector2
var default_position: Vector2

var eyes_timer: int

onready var sprite_eyes = $SpriteContainer/Eyes
onready var sprite_container = $SpriteContainer


func get_class():
	return "Player"


func interpolation(a, b, t):
	var one_minus_t = 1 - t
	return a + (b - a) * (1 - one_minus_t * one_minus_t * one_minus_t)


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


func teleport(movement):
	animation_timer = 0
	real_position -= movement
	position = real_position
	previous_position = position


func move(direction, invert_dir = false):
	facing = direction
	if not invert_dir:
		MoveLogger.new_move()
	eyes_timer = EYES_TIME
	var direction_multiplier = (-int(invert_dir) + .5) * 2
	direction *= direction_multiplier
	var collided = false
	if not invert_dir:
		collided = collide(direction, real_position)
	if direction * direction_multiplier == self.direction:
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
				Global.level_container.to_big(sprite_container, direction)
			elif collided.get_class() == "Exit":
				Global.level_container.to_small(sprite_container, direction)
			if not invert_dir:
				MoveLogger.add_action_to_move(
					self, direction,
					new_position - real_position - direction * Global.TILESIZE
				)
			real_position = new_position
		collision_mask |= 2
	animation_timer = Global.ANIMATION_TIME
	self.direction = direction


func _ready():
	default_position = position
	real_position = position
	previous_position = position
	Global.connect("reset", self, "reset")
	Global.connect("set_default_pos", self, "set_default_pos")


func reset():
	real_position = default_position
	previous_position = position
	animation_timer = Global.ANIMATION_TIME
	eyes_timer = 1


func _input(event):
	if not Global.lock_movement:
		if event.is_action_pressed("ui_left"):
			move(Vector2.LEFT)
		elif event.is_action_pressed("ui_right"):
			move(Vector2.RIGHT)
		elif event.is_action_pressed("ui_up"):
			move(Vector2.UP)
		elif event.is_action_pressed("ui_down"):
			move(Vector2.DOWN)


func is_direction_held():
	match direction:
		Vector2.LEFT:
			return Input.is_action_pressed("ui_left")
		Vector2.RIGHT:
			return Input.is_action_pressed("ui_right")
		Vector2.UP:
			return Input.is_action_pressed("ui_up")
		Vector2.DOWN:
			return Input.is_action_pressed("ui_down")


func set_default_pos():
	default_position = real_position


func _physics_process(delta):
	if animation_timer:
		animation_timer -= 1
		position = interpolation(
			previous_position,
			real_position,
			1.0 - float(animation_timer) / Global.ANIMATION_TIME
		)
		if animation_timer == 0:
			Global.emit_signal("move_ended")
			if not visible:
				visible = true
			previous_position = real_position
			if is_direction_held():
				move(direction)
	if eyes_timer:
		eyes_timer -= 1
		if eyes_timer > EYES_SMALL_OFFSET_THRESHOLD:
			sprite_eyes.position = facing * EYES_BIG_OFFSET
		elif eyes_timer:
			sprite_eyes.position = facing * EYES_SMALL_OFFSET
		else:
			sprite_eyes.position = Vector2.ZERO
			
