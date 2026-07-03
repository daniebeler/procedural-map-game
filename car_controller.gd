extends VehicleBody3D

@export var max_engine_force: float = 400.0
@export var max_steering_angle: float = 0.5
@export var brake_force: float = 10.0

func _physics_process(_delta: float) -> void:
	# 1. Steering: Use A/D or Left/Right arrows
	steering = Input.get_axis("ui_right", "ui_left") * max_steering_angle
	
	# 2. Acceleration: Use W/S or Up/Down arrows
	# Note: Input.get_axis("down", "up") gives -1 for S/Down and +1 for W/Up
	engine_force = Input.get_axis("ui_down", "ui_up") * max_engine_force
	
	# 3. Braking: Use Spacebar
	if Input.is_action_pressed("ui_select"): # Spacebar
		brake = brake_force
	else:
		brake = 0.0
