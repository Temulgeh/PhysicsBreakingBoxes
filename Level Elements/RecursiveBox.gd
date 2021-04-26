extends KinematicBody2D


var previous_position: Vector2
var real_position: Vector2
var animation_timer: int
var default_position: Vector2

onready var placeholder_sprite = $PlaceholderSprite


func get_class():
	return "RecursiveBox"


func _init():
	Global.recursive_box = self


func interpolation(a, b, t):
	var one_minus_t = 1 - t
	return a + (b - a) * (1 - one_minus_t * one_minus_t * one_minus_t)


func teleport(movement):
	animation_timer = 0
	real_position -= movement
	position = real_position
	previous_position = position


func custom_move(to_position):
	real_position = to_position
	set_default_pos()
	animation_timer = Global.ANIMATION_TIME


func set_default_pos():
	default_position = real_position


func move(direction, invert_dir = false):
	var direction_multiplier = (-int(invert_dir) + .5) * 2
	var movement = direction * Global.TILESIZE * direction_multiplier
	var collided = false
	var collision = move_and_collide(movement, true, true, true)
	if collision and not invert_dir:
		if collision.collider.has_method("move"):
			collided = collision.collider.move(direction, false)
		else:
			Global.lock_movement = self
			# dynamic typing bad >:( but i still used it :(
			match direction:
				Vector2.LEFT:
					collided = Global.level.exit_right
				Vector2.RIGHT:
					collided = Global.level.exit_left
				Vector2.UP:
					collided = Global.level.exit_down
				Vector2.DOWN:
					collided = Global.level.exit_up
	previous_position = position
	if not collided:
		if not invert_dir:
			MoveLogger.add_action_to_move(self, direction)
		real_position += movement
	animation_timer = Global.ANIMATION_TIME
	return collided


func _ready():
	default_position = position
	previous_position = position
	real_position = position
	placeholder_sprite.visible = false
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
			if Global.lock_movement == self:
				Global.lock_movement = null
	# hard coded values because i don't want to think
	Global.level_container.smol.change_position(position + Vector2(96, -8))
	Global.level_container.beeg.change_position(
		position * -(float(Global.MAIN_BOX_SIZE) / Global.TILESIZE) +
		Vector2(248, 144)
	)
