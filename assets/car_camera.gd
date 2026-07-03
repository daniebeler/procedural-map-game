extends Camera3D

@export var target_node: Node3D
@export var car_node: Node3D

@export var follow_speed: float = 5.0
@export var look_speed: float = 7.0

func _physics_process(delta: float) -> void:
	if not target_node or not car_node: return
	
	# 1. Smoothly interpolate the position toward the target behind the car
	var target_pos = target_node.global_position
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	# 2. Smoothly rotate the camera to look at the center of the car body
	var target_transform = global_transform.looking_at(car_node.global_position, Vector3.UP)
	global_transform.basis = global_transform.basis.slerp(target_transform.basis, look_speed * delta)
