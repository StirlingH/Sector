extends ShipCharacter


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _get_input():
	rotation_input = Input.get_axis("Left", "Right")
	thrust_input = Input.get_axis("Down", "Up")

	brake_active = Input.is_action_pressed("Brake")
