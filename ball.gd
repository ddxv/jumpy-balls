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

var velocity := Vector3.ZERO
var start_touch_position := Vector2.ZERO
var current_touch_position := Vector2.ZERO
var is_touching := false
var is_jump := false
var touch_time := 0.0
var max_touch_time_for_jump := 0.2  # Time threshold to consider a touch as a jump


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
	var height = max(round(abs(ball_position.y) / Globals.CHUNK_SIZE), 1)
	var distance = max(round((abs(ball_position.x) + abs(ball_position.z)) / Globals.CHUNK_SIZE), 1)
	score = round(distance * height)
	high_score = max(score, high_score)
	var score_label = get_node("/root/Level/ScoreLabel")
	score_label.text = " Distance: " + str(distance)
	score_label.text += " Height: " + str(height)
	score_label.text += " Score: " + str(score)
	score_label.text += " High Score: " + str(high_score)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		is_jump = is_touching and not event.pressed
		is_touching = event.pressed
		if is_touching:
			start_touch_position = event.position
			touch_time = 0
		else:
			velocity.x = 0

	elif event is InputEventScreenDrag:
		# start_touch_position = event.position
		current_touch_position = event.position


func _physics_process(delta):
	var glide_direction = Vector3(0, 0, 0)
	var base_speed = MAX_FORCE / float(90) * delta
	velocity = Vector3(0, 0, -2)
	ball_position = global_transform.origin
	var camera_position = ball_position + Globals.CAMERA_LOCAL_POSITION
	var cam_to_ball_dir: Vector3 = camera_position.direction_to(ball_position)
	var moving_dir: Vector3 = last_position.direction_to(ball_position)

	if is_touching:
		touch_time += delta
		if touch_time > max_touch_time_for_jump:
			velocity.x = ((current_touch_position.x - start_touch_position.x) * base_speed)
			print("TOUCH vel=", velocity)
			apply_central_force(velocity)
			angular_velocity.z += rolling_force * delta * -velocity.x
			glide_direction.x = velocity.x / 10
	else:
		if is_jump:
			if floor_check.is_colliding():
				moving_dir.y = abs(moving_dir.y)
				var jump_direction = Vector3(0, 1, 0) + moving_dir
				print("jump, vel=", velocity)
				print("jump, dir=", jump_direction)
				glide_direction.y = 2
				apply_central_impulse(jump_direction * MAX_FORCE)
			else:
				print("air jump")
				apply_central_impulse(cam_to_ball_dir * JUMP_FORCE)
			is_jump = false
		touch_time = 0

	# As the ball moves, move other objects with it
	# camera_rig.global_transform.origin = lerp(camera_position, camera_position, 1)
	camera_rig.global_transform.origin = camera_position
	floor_check.global_transform.origin = global_transform.origin

	# Steady forward rolling addition
	angular_velocity.x -= rolling_force * delta

	# Clamping angular velocity to MAX_SPIN
	angular_velocity.x = clamp(angular_velocity.x, -MAX_SPIN, MAX_SPIN)
	angular_velocity.y = clamp(angular_velocity.y, -MAX_SPIN, MAX_SPIN)
	angular_velocity.z = clamp(angular_velocity.z, -MAX_SPIN, MAX_SPIN)
	# print("my angular", angular_velocity)

	if not floor_check.is_colliding():
		glide_direction += Vector3(0, -2, 0)
		print("gliding=", glide_direction)
		apply_central_impulse(glide_direction)

	# TODO: Should be + radius of ball or use floor_check raycast
	if global_transform.origin.y < Globals.DEATH_HEIGHT + 1:
		game_over()
