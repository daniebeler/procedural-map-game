extends Node

@export var flying_cam: Camera3D
@export var player_car: Node3D        # Changed to Node3D to support either RigidBody3D or VehicleBody3D
@export var smooth_camera: Camera3D   # Add your new standalone SmoothCamera here
@export var terrain_manager: Node3D

enum Mode { FLYING, CAR }
var current_mode: Mode = Mode.FLYING

func _ready() -> void:
	# Start in flying mode
	set_mode(Mode.FLYING)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_P):
		if current_mode == Mode.FLYING:
			set_mode(Mode.CAR)
		else:
			set_mode(Mode.FLYING)

func set_mode(new_mode: Mode) -> void:
	current_mode = new_mode
	
	if current_mode == Mode.FLYING:
		# 1. Enable Flying Camera
		if flying_cam:
			flying_cam.make_current()
			flying_cam.set_process(true)
			flying_cam.set_process_input(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# 2. Disable Standalone Car Camera tracking
		if smooth_camera:
			smooth_camera.set_physics_process(false)
		
		# 3. Disable Car Physics
		if player_car:
			player_car.set_physics_process(false)
			if player_car is RigidBody3D:
				player_car.freeze = true # Keeps RigidBody suspended in the air
		
		# 4. Tell terrain generator to track the Flying Cam
		if terrain_manager and flying_cam:
			terrain_manager.target_node = flying_cam
			
	elif current_mode == Mode.CAR:
		# 1. Disable Flying Camera inputs
		if flying_cam:
			flying_cam.set_process(false)
			flying_cam.set_process_input(false)
			
		# 2. Enable Car Physics
		if player_car:
			player_car.set_physics_process(true)
			if player_car is RigidBody3D:
				player_car.freeze = false
		
		# 3. Switch to and activate the Smooth Tracking Camera
		if smooth_camera:
			smooth_camera.make_current()
			smooth_camera.set_physics_process(true)
		
		# Release mouse capture so you can click or look at debug settings if needed
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		# 4. Tell terrain generator to track the Car
		if terrain_manager and player_car:
			terrain_manager.target_node = player_car
