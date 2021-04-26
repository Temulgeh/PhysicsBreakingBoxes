extends Camera2D


const SHAKE_FORCE = 5.0
const SHAKE_DECAY = .9
const SHAKE_THRESHOLD = 0.1


var shakiness: float


func _ready():
	Global.camera = self


func shake():
	shakiness = SHAKE_FORCE


func _physics_process(delta):
	if shakiness:
		offset = Vector2.RIGHT.rotated(rand_range(0, 2 * PI)) * shakiness
		shakiness *= SHAKE_DECAY
		if shakiness < SHAKE_THRESHOLD:
			offset = Vector2.ZERO
			shakiness = 0.0
