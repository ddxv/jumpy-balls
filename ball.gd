extends RigidBody3D

const acceleration = 1.0001
var motion = Vector3()
const max_speed = -10
const JUMP_FORCE = Vector3(0, 40, 0)  # Adjust the Y value to set jump strength

var is_on_ground = false  # Variable to check if the player is on the ground

# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	motion.x = Input.get_axis("move_left", "move_right") * 4
	if Input.is_action_pressed("move_forward"):
		motion.z = motion.z + Input.get_axis("move_forward", "move_back") * acceleration
		motion.z = max(max_speed, motion.z)
	else:
		motion.z = motion.z * 0.9
	# Check for jump input
	if (Input.is_action_just_pressed("jump") and is_on_ground):
		print("jump!")
		apply_central_impulse(JUMP_FORCE)
		motion.y += JUMP_FORCE
		is_on_ground = false  # Player has jumped, so they're no longer on the ground
	apply_central_force(motion * 1200.0 * delta)


	if global_transform.origin.y < -10:
		game_over()

func game_over():
	# Handle the game over state
	print("Game Over!")  # Replace this with your game over logic
	get_tree().reload_current_scene()

# Override the _integrate_forces function to detect if the player is on the ground
func _integrate_forces(state):
	var local_floor_normal = Vector3(0, 1, 0)
	is_on_ground = state.get_contact_count() > 0
	print(is_on_ground)
	#for i in range(state.get_contact_count()):
		#if state.get_contact_local_normal(i).dot(local_floor_normal) > 0.9:
			#is_on_ground = true
			#break
