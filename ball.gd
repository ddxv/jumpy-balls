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

	

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta):
	#var y_speed = 0
	#var c = get_contact_count()
	#if c > 0:
		#is_on_ground = true
		#print('on ground')
	#elif last_contact_count ==0 and c==0:
		#print('off ground')
		#is_on_ground = false
		#y_speed = motion.y
	#last_contact_count = c
	#motion.x = Input.get_axis("move_left", "move_right") * force_side
	#var speed = min(min_speed, motion.z*(1+c))
	#if Input.is_action_pressed("move_forward") and not is_on_ground:
		#speed = speed * acceleration
		#speed = max(max_force, speed)
	#else:
		#speed = min_speed
	#motion.z = speed
#
	## Check for jump input
	#if not is_on_ground:
		#print("add falling speed")
		#y_speed = min(abs(y_speed),-1) * 1200 * delta
	#if (Input.is_action_just_pressed("jump") and is_on_ground):
		#print("jump!")
		#y_speed = abs(speed) + y_speed + JUMP_FORCE * 10
		#apply_central_impulse(Vector3(0,JUMP_FORCE,0))
	#motion.y = y_speed
	#print(motion)
	#apply_central_force(motion *2* delta)
#


func game_over():
	# Handle the game over state
	print("Game Over!")  # Replace this with your game over logic
	get_tree().reload_current_scene()





func _physics_process(delta):
	var camera_position: Vector3 = CameraRig.global_transform.origin
	var ball_position: Vector3 = global_transform.origin
	
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
		
	if global_transform.origin.y < -49:
		game_over()




## Override the _integrate_forces function to detect if the player is on the ground
#func _integrate_forces(state):
	#is_on_ground = state.get_contact_count() > 0
	##for i in range(state.get_contact_count()):
		##if state.get_contact_local_normal(i).dot(local_floor_normal) > 0.9:
			##is_on_ground = true
			##break
			

## Callback function for the body_entered signal
#func _on_body_entered(body):
	#print("RigidBody3D is touching the ...")
	#if body is GridMap:
		#print("RigidBody3D is touching the GridMap")
