extends RigidBody3D

const acceleration = 1.001

var motion = Vector3()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	motion.x = Input.get_axis("move_left", "move_right")
	if Input.is_action_pressed("move_forward"):
		motion.z = motion.z + Input.get_axis("move_forward", "move_back")
		motion = motion * acceleration
	else:
		motion.z = motion.z * 0.9
	print(motion)
	apply_central_force(motion * 1200.0 * delta)
	
