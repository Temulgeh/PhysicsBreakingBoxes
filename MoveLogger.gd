extends Node


var move_stack = []
var current_move = []

var animation_timer: int


func _ready():
	Global.connect("reset", self, "reset")


func reset():
	move_stack = []
	current_move = []
	animation_timer = 0


func new_move():
	if len(move_stack) == Settings.max_undos:
		move_stack.pop_front()
	if current_move:
		move_stack.append(current_move.duplicate())
	current_move = []


func add_action_to_move(node, direction, teleport = Vector2.ZERO):
	current_move.append({ "node": node, "direction": direction, "teleport": teleport })


func cancel_move():
	if not current_move and move_stack:
		current_move = move_stack.pop_back()
	for action in current_move:
		action.node.teleport(action.teleport)
		action.node.move(action.direction, true)
	if move_stack:
		current_move = move_stack.pop_back()
	else:
		current_move = []
	Global.lock_movement = self
	animation_timer = Global.ANIMATION_TIME


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		cancel_move()


func _physics_process(delta):
	if animation_timer:
		animation_timer -= 1
		if animation_timer == 0:
			if Global.lock_movement == self:
				Global.lock_movement = null
			if Input.is_action_pressed("ui_cancel"):
				cancel_move()
