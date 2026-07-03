extends Camera3D

@export var movement_speed: float = 20.0
@export var mouse_sensitivity: float = 0.1

var rotation_x: float = 0.0
var rotation_y: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_x -= event.relative.x * mouse_sensitivity
		rotation_y -= event.relative.y * mouse_sensitivity
		rotation_y = clamp(rotation_y, -89.0, 89.0)
		
		transform.basis = Basis()
		rotate_object_local(Vector3.UP, deg_to_rad(rotation_x))
		rotate_object_local(Vector3.RIGHT, deg_to_rad(rotation_y))
		
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
		
	var input_dir := Vector3.ZERO
	
	if Input.is_key_pressed(KEY_W):
		input_dir.z -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.z += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_E):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_Q):
		input_dir.y -= 1
		
	input_dir = input_dir.normalized()
	
	var forward := global_transform.basis.z
	var right := global_transform.basis.x
	var up := Vector3.UP
	
	var direction := (right * input_dir.x) + (up * input_dir.y) + (forward * input_dir.z)
	global_translate(direction * movement_speed * delta)
