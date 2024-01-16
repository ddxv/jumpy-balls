extends RigidBody3D

const acceleration = 1.01
var motion = Vector3()
const max_force = -200
const min_speed = -100
const force_side = min_speed
const JUMP_FORCE = -max_force * 2 
var last_contact_count =0;

var CameraRig;
var FloorCheck;
var rolling_force = 40

var last_position

var score = 0

var ball_position

var is_on_ground = false  # Variable to check if the player is on the ground


# Called when the node enters the scene tree for the first time.
func _ready():
	continuous_cd = true
	set_contact_monitor(true)
	set_max_contacts_reported (2)
	var parent = get_parent()
	CameraRig = parent.get_node("CameraRig")
	CameraRig.top_level =true
	FloorCheck = parent.get_node("FloorCheck")
	FloorCheck.top_level = true
	last_position = global_transform.origin


func game_over():
	# Handle the game over state
	print("Game Over!")  # Replace this with your game over logic
	get_tree().reload_current_scene()


func _process(delta):
	score = round(abs(ball_position.x) + abs(ball_position.z))
	var ScoreLabel = get_node("/root/Level/ScoreLabel")
	ScoreLabel.text = "Score: " + str(score)



func _physics_process(delta):
	var camera_position: Vector3 = CameraRig.global_transform.origin
	ball_position = global_transform.origin
	
	var dir:Vector3 = camera_position.direction_to(ball_position)

	var moving_dir:Vector3 = last_position.direction_to(ball_position)

	CameraRig.global_transform.origin = lerp(
		camera_position, 
		ball_position+Vector3(0,2,2), 1
	)
	# As the ball moves, move the raycast along with it
	FloorCheck.global_transform.origin = global_transform.origin

	if Input.is_action_pressed("move_forward"):
		angular_velocity.x -= rolling_force*delta
	elif Input.is_action_pressed("move_back"):
		angular_velocity.x += rolling_force*delta
	if Input.is_action_pressed("move_left"):
		angular_velocity.z += rolling_force*delta
	elif Input.is_action_pressed("move_right"):
		angular_velocity.z -= rolling_force*delta

	# When the ball is on the floor and the user presses jump button,
	# add impulse moving the ball up.
	if Input.is_action_just_pressed("jump"):
		if FloorCheck.is_colliding():
			print("jump")
			#apply_impulse(Vector3(), Vector3.UP*1000)
			apply_central_impulse((moving_dir*100+Vector3(0,1,0)*100))
		else:
			print("air jump")
			apply_central_impulse(dir*100)
	if not FloorCheck.is_colliding():
		apply_central_impulse(Vector3(0,-1,0))
		
	if global_transform.origin.y < -49:
		game_over()



