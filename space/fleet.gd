extends RigidBody2D
class_name Fleet

@export var max_thrust: float = 400.0
@export var max_speed: float = 300.0
@export var rotation_thrust: float = 4.0
# PID Controller parameters
@export var Kp = 4.0  # Proportional gain
@export var Ki = 0.1  # Integral gain
@export var Kd = 4.0  # Derivative gain

var target_position: Vector2

# PID controller variables
var integral = Vector2.ZERO
var rot_integral: float = 0.0
var previous_error = Vector2.ZERO
var rot_previous_error: float = 0.0

var min_vel_for_rot: float = 5.0


func _physics_process(delta):
	_get_input()
	pid_controller(delta)
	handle_rotation(delta)


func _get_input():
	pass
	
	
func pid_controller(delta):
	var error = target_position - position
	
	integral += error * delta
	#integral = clamp(integral, -10.0, 10.0)
	
	# Calculate derivative term
	var derivative = (error - previous_error) / delta
	previous_error = error
	
	var thrust = Kp * error + Ki * integral + Kd * derivative
	thrust = scale_to_max(thrust, max_thrust)
	
	apply_central_force(thrust)
	
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed


func scale_to_max(vector: Vector2, max_value: float) -> Vector2:
	# Find the largest absolute component (considering negative values too)
	var max_component = max(abs(vector.x), abs(vector.y))
	
	# If already within limits, return the original vector
	if max_component <= max_value:
		return vector
	
	# Calculate the scale factor needed
	var scale_factor = max_value / max_component
	
	# Return the scaled vector
	return vector * scale_factor


func handle_rotation(delta):
	if linear_velocity.length() < min_vel_for_rot:
		print("no torque")
		return
	var target_angle = (linear_velocity).angle() + PI/2
	var current_angle = rotation
	
	# Calculate the angular error (shortest path)
	var error = short_angle_distance(current_angle, target_angle)
	
	# Calculate integral term (with anti-windup)
	rot_integral += error * delta
	rot_integral = clamp(rot_integral, -10.0, 10.0)  # Prevent integral windup
	
	# Calculate derivative term
	var derivative = (error - rot_previous_error) / delta
	rot_previous_error = error
	
	# Calculate PID output
	var torque_amount = Kp * error + Ki * rot_integral + Kd * derivative
	
	# Clamp torque to thrust
	torque_amount = clamp(torque_amount, -rotation_thrust, rotation_thrust)
	
	# Apply torque directly - this is physically correct for rotation in space
	apply_torque(torque_amount * 1000)
	
	
# Function to calculate the shortest angular distance between two angles
func short_angle_distance(from_angle, to_angle):
	var max_angle = 2.0 * PI
	var difference = fmod(to_angle - from_angle, max_angle)
	return fmod(2.0 * difference, max_angle) - difference
