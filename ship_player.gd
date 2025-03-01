extends ShipCharacter

# only necessary for mouse look mode
@export var max_angular_velocity: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _get_input():
	if Input.is_action_pressed("Shift"):
		rotation_input = Input.get_axis("Left", "Right")
		thrust_input = Input.get_axis("Down", "Up")
	else:
		# slow down if spinning too fast
		if abs(angular_velocity) > max_angular_velocity:
			rotation_input = sign(angular_velocity) * -1
		else:
			var angle_to_mouse = global_position.direction_to(get_global_mouse_position()).angle() + PI/2
			var angle_to_mouse_from_face = fmod((angle_to_mouse - rotation + PI), (2 * PI)) - PI
			
			if angle_to_mouse_from_face < -0.001:
				rotation_input = -1
			elif angle_to_mouse_from_face > 0.001:
				rotation_input = 1
			else:
				rotation_input = 0
			
			# if within an angle range and your angular velocity is aimed at the goal, cap ang vel
			var threshold = PI/4
			
			if abs(angle_to_mouse_from_face) < threshold && sign(angular_velocity) == sign(angle_to_mouse_from_face):
				#scale between 0 angular velocity at no angle and max at the threshold angle
				var scaled_max_velocity = abs(angle_to_mouse_from_face) / threshold * max_angular_velocity
				# Clamp angular velocity while preserving sign
				angular_velocity = sign(angular_velocity) * min(abs(angular_velocity), scaled_max_velocity)

	brake_active = Input.is_action_pressed("Brake")
