extends RigidBody3D

const ACCELERATION = 1.01
const MAX_FORCE = 200
const MIN_SPEED = -100
const FORCE_SIDE = MIN_SPEED * 2
const JUMP_FORCE = MAX_FORCE
const MAX_SPIN = 500

var last_contact_count = 0
var motion = Vector3()
var rolling_force = 40
var score = 0
var high_score = 0
var is_on_ground = false  # Variable to check if the player is on the ground

var ball_position
var last_position
var camera_rig
var floor_check


# Called when the node enters the scene tree for the first time.
func _ready():
	continuous_cd = true
	set_contact_monitor(true)
	set_max_contacts_reported(2)
	var parent = get_parent()
	camera_rig = parent.get_node("CameraRig")
	camera_rig.top_level = true
	floor_check = parent.get_node("FloorCheck")
	floor_check.top_level = true
	last_position = global_transform.origin


func game_over():
	# Handle the game over state
	print("Game Over!")  # Replace this with your game over logic
	get_tree().reload_current_scene()


func _process(_delta):
	var height = round(abs(ball_position.z) / Globals.CHUNK_SIZE)
	var distance = round((abs(ball_position.x) + abs(ball_position.z)) / Globals.CHUNK_SIZE)
	score = round(distance * height)
	high_score = max(score, high_score)
	var score_label = get_node("/root/Level/ScoreLabel")
	score_label.text = " Distance: " + str(distance)
	score_label.text += " Height: " + str(height)
	score_label.text += " Score: " + str(score)
	score_label.text += " High Score: " + str(high_score)


func _physics_process(delta):
	var glide_direction = Vector3(0, 0, 0)
	var camera_position: Vector3 = camera_rig.global_transform.origin
	ball_position = global_transform.origin

	var cam_to_ball_dir: Vector3 = camera_position.direction_to(ball_position)

	var moving_dir: Vector3 = last_position.direction_to(ball_position)

	camera_rig.global_transform.origin = lerp(camera_position, ball_position + Vector3(0, 2, 3), 1)
	# As the ball moves, move the raycast along with it
	floor_check.global_transform.origin = global_transform.origin
	if Input.is_action_pressed("move_forward"):
		angular_velocity.x -= rolling_force * delta
		glide_direction.y = 1
	elif Input.is_action_pressed("move_back"):
		angular_velocity.x += rolling_force * delta
	if Input.is_action_pressed("move_left"):
		angular_velocity.z += rolling_force * delta
		glide_direction.x = -1
	elif Input.is_action_pressed("move_right"):
		angular_velocity.z -= rolling_force * delta
		glide_direction.x = 1
	# Clamping angular velocity to MAX_SPIN
	angular_velocity.x = clamp(angular_velocity.x, -MAX_SPIN, MAX_SPIN)
	angular_velocity.y = clamp(angular_velocity.y, -MAX_SPIN, MAX_SPIN)
	angular_velocity.z = clamp(angular_velocity.z, -MAX_SPIN, MAX_SPIN)
	# print("my angular", angular_velocity)
	# When the ball is on the floor and the user presses jump button,
	# add impulse moving the ball up.
	if Input.is_action_just_pressed("jump"):
		if floor_check.is_colliding():
			print("jump")
			#apply_impulse(Vector3(), Vector3.UP*1000)
			apply_central_impulse(moving_dir * MAX_FORCE + Vector3(0, 1, 0) * MAX_FORCE)
		else:
			print("air jump")
			apply_central_impulse(cam_to_ball_dir * JUMP_FORCE)
	if not floor_check.is_colliding():
		glide_direction += Vector3(0, -2, 0)
		apply_central_impulse(glide_direction)

	# TODO: Should be + radius of ball or use floor_check raycast
	if global_transform.origin.y < Globals.DEATH_HEIGHT + 1:
		game_over()
