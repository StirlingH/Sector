extends Fleet

func _get_input():
	if Input.is_action_pressed("Left Click"):
		target_position = get_global_mouse_position()
