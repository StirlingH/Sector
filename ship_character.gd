extends RigidBody2D
class_name ShipCharacter


@export var thrust_power: float = 10000.0
@export var reverse_thrust_power: float = -5000.0

@export var rotation_thrust: float = 4.0

var thrust_input: float = 0.0         # Range: -1.0 (full reverse) to 1.0 (full forward)
var rotation_input: float = 0.0       # Range: -1.0 (left) to 1.0 (right)
var brake_active: bool = false

func _ready():
	pass

func _physics_process(delta):
	_get_input(delta)
	handle_rotation(delta)
	handle_thrust(delta)
	handle_brake()


func _get_input(delta):
	pass


func handle_rotation(delta):
	angular_velocity += rotation_input * rotation_thrust * delta


func handle_thrust(delta):
	# Calculate the thrust direction based on the ship's rotation
	var thrust_direction = Vector2(cos(rotation - PI/2), sin(rotation - PI/2))
	
	if thrust_input > 0:
		apply_central_force(thrust_direction * thrust_power * delta)
	elif thrust_input < 0:
		apply_central_force(thrust_direction * reverse_thrust_power * delta)


# Dampen movement
func handle_brake():
	if brake_active:
		# You can still input spin but it sets a speed cap due to equilibrium
		linear_damp = 1
		angular_damp = 1
	else:
		linear_damp = 0
		angular_damp = 0
