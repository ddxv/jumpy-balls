extends RigidBody3D

const acceleration = 1.01
var motion = Vector3()
const max_force = -200
const min_speed = -100
const force_side = min_speed
const JUMP_FORCE = -max_force * 2 
var last_contact_count =0;

var is_on_ground = false  # Variable to check if the player is on the ground


# Called when the node enters the scene tree for the first time.
func _ready():
	continuous_cd = true
	set_contact_monitor(true)
	set_max_contacts_reported (2)
	#connect("body_entered", _on_body_entered)
	 

func _on_body_exited(body:Node):
	print(body, " exited")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var y_speed = 0
	var c = get_contact_count()
	if c > 0:
		is_on_ground = true
		print('on ground')
	elif last_contact_count ==0 and c==0:
		print('off ground')
		is_on_ground = false
		y_speed = motion.y
	last_contact_count = c
	motion.x = Input.get_axis("move_left", "move_right") * force_side
	var speed = min(min_speed, motion.z*(1+c))
	if Input.is_action_pressed("move_forward") and not is_on_ground:
		speed = speed * acceleration
		speed = max(max_force, speed)
	else:
		speed = min_speed
	motion.z = speed

	# Check for jump input
	if not is_on_ground:
		print("add falling speed")
		y_speed = min(abs(y_speed),-1) * 1200 * delta
	if (Input.is_action_just_pressed("jump") and is_on_ground):
		print("jump!")
		y_speed = abs(speed) + y_speed + JUMP_FORCE * 10
		apply_central_impulse(Vector3(0,JUMP_FORCE,0))
	motion.y = y_speed
	print(motion)
	apply_central_force(motion *2* delta)


	if global_transform.origin.y < -49:
		game_over()

func game_over():
	# Handle the game over state
	print("Game Over!")  # Replace this with your game over logic
	get_tree().reload_current_scene()

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
