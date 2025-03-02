extends ShipCharacter

# only necessary for mouse look mode
@export var max_angular_velocity: float = 2.0
# PID Controller parameters
@export var Kp = 4.0  # Proportional gain
@export var Ki = 0.1  # Integral gain
@export var Kd = 4.0  # Derivative gain

# PID controller variables
var integral = 0.0
var previous_error = 0.0

var mouse_look: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _get_input(delta):
	if Input.is_action_just_pressed("Flight Mode Toggle"):
		mouse_look = !mouse_look
		if mouse_look:
			rotation_input = 0
		
	if !mouse_look:
		rotation_input = Input.get_axis("Left", "Right")
	else:
		var target_angle = (get_global_mouse_position() - global_position).angle() + PI/2
		var current_angle = rotation
		
		# Calculate the angular error (shortest path)
		var error = short_angle_distance(current_angle, target_angle)
		
		# Calculate integral term (with anti-windup)
		integral += error * delta
		integral = clamp(integral, -10.0, 10.0)  # Prevent integral windup
		
		# Calculate derivative term
		var derivative = (error - previous_error) / delta
		previous_error = error
		
		# Calculate PID output
		var torque_amount = Kp * error + Ki * integral + Kd * derivative
		
		# Clamp torque to thrust
		torque_amount = clamp(torque_amount, -rotation_thrust, rotation_thrust)
		
		# Apply torque directly - this is physically correct for rotation in space
		apply_torque(torque_amount * 1000)
		
		
		
	thrust_input = Input.get_axis("Down", "Up")
	brake_active = Input.is_action_pressed("Brake")


func handle_thrust(delta):
	super.handle_thrust(delta)
	if mouse_look:
		var strafe = Input.get_axis("Left", "Right")
		var forwards = get_forwards()
		if strafe > 0:
			apply_central_force(forwards.rotated(deg_to_rad(90)) * thrust_power * delta)
		elif strafe < 0:
			apply_central_force(forwards.rotated(deg_to_rad(-90)) * thrust_power * delta)


# Function to calculate the shortest angular distance between two angles
func short_angle_distance(from_angle, to_angle):
	var max_angle = 2.0 * PI
	var difference = fmod(to_angle - from_angle, max_angle)
	return fmod(2.0 * difference, max_angle) - difference
