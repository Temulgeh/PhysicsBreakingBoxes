extends Node2D


var animation_timer: int
var small_start: Transform2D
var big_start: Transform2D
var small_destination: Transform2D
var big_destination: Transform2D
var small_scale: float
var big_scale: float

onready var beeg = $ImHereJustForZSort/Beeg
onready var smol = $Smol
onready var transition_big = $TransitionBig
onready var transition_small = $TransitionSmall


func _init():
	Global.level_container = self


func _ready():
	beeg.change_scale(float(Global.MAIN_BOX_SIZE) / Global.TILESIZE)
	smol.change_scale(float(Global.TILESIZE) / Global.MAIN_BOX_SIZE)
	beeg.set_world(Global.world)
	smol.set_world(Global.world)
	beeg.visible = true
	smol.visible = true
	small_scale = float(Global.TILESIZE) / Global.MAIN_BOX_SIZE
	big_scale = float(Global.MAIN_BOX_SIZE) / Global.TILESIZE


func to_small(node, direction):
	var copy_small = node.duplicate()
	var copy_big = node.duplicate()
	transition_small.add_child(copy_small)
	transition_big.add_child(copy_big)
	transition_small.transform = Transform2D.IDENTITY
	transition_big.transform = Transform2D.IDENTITY
	transition_small.position = (
		Global.recursive_box.position + Vector2(104, 0) -
		direction * Global.TILESIZE
	)
	transition_big.position = (
		Vector2(248, 144) - Global.MAIN_BOX_SIZE * direction
	)
	transition_big.scale = Vector2(big_scale, big_scale)
	small_start = transition_small.transform
	big_start = transition_big.transform
	animation_timer = Global.ANIMATION_TIME
	var destination_position: Vector2
	match direction:
		Vector2.LEFT:
			destination_position = Global.level.exit_right.position + direction * Global.TILESIZE
		Vector2.RIGHT:
			destination_position = Global.level.exit_left.position + direction * Global.TILESIZE
		Vector2.UP:
			destination_position = Global.level.exit_down.position + direction * Global.TILESIZE
		Vector2.DOWN:
			destination_position = Global.level.exit_up.position + direction * Global.TILESIZE
	big_destination = Transform2D.IDENTITY.translated(destination_position + Vector2(104, 0))
	small_destination = Transform2D.IDENTITY.scaled(
		Vector2(small_scale, small_scale)
	).translated(destination_position - Vector2(
		Global.MAIN_BOX_SIZE / 2, Global.MAIN_BOX_SIZE / 2
	))
	small_destination.origin += (
		Global.recursive_box.position + Vector2(104, 0)
	)

func to_big(node, direction):
	var copy_small = node.duplicate()
	var copy_big = node.duplicate()
	transition_small.add_child(copy_small)
	transition_big.add_child(copy_big)
	transition_small.transform = Transform2D.IDENTITY
	transition_big.transform = Transform2D.IDENTITY
	var start_position: Vector2
	match direction:
		Vector2.LEFT:
			start_position = Global.level.exit_left.position - direction * Global.TILESIZE
		Vector2.RIGHT:
			start_position = Global.level.exit_right.position - direction * Global.TILESIZE
		Vector2.UP:
			start_position = Global.level.exit_up.position - direction * Global.TILESIZE
		Vector2.DOWN:
			start_position = Global.level.exit_down.position - direction * Global.TILESIZE
	transition_small.position = (
		Global.recursive_box.position + (start_position - Vector2(
			Global.MAIN_BOX_SIZE / 2, Global.MAIN_BOX_SIZE / 2
		)) * small_scale +
		Vector2(104, 0)
	)
	transition_small.scale = Vector2(small_scale, small_scale)
	transition_big.position = (
		start_position + Vector2(104, 0)
	)
	small_start = transition_small.transform
	big_start = transition_big.transform
	animation_timer = Global.ANIMATION_TIME
	big_destination = Transform2D.IDENTITY.scaled(
		Vector2(big_scale, big_scale)
	).translated(direction * Global.TILESIZE)
	big_destination.origin += Vector2(248, 144)
	small_destination = Transform2D.IDENTITY.translated(
		Global.recursive_box.position + Vector2(104, 0) + direction * Global.TILESIZE
	)


func _physics_process(delta):
	if animation_timer:
		animation_timer -= 1
		transition_small.transform = small_start.interpolate_with(
			small_destination,
			1.0 - float(animation_timer) / Global.ANIMATION_TIME
		)
		transition_big.transform = big_start.interpolate_with(
			big_destination,
			1.0 - float(animation_timer) / Global.ANIMATION_TIME
		)
		if animation_timer == 0:
			for child in transition_big.get_children():
				child.queue_free()
			for child in transition_small.get_children():
				child.queue_free()
