extends RefCounted
class_name FoliageScatterer

func get_tree_transforms(coord: Vector2i, size: float, noise: FastNoiseLite, max_h: float) -> Array[Transform3D]:
	var transforms: Array[Transform3D] = []
	var rng := RandomNumberGenerator.new()
	
	# Hash the coordinate so chunks always spawn the same trees in the same spots
	rng.seed = hash(coord) 
	
	var offset_x = coord.x * size
	var offset_z = coord.y * size
	
	# Try to spawn 15 trees per chunk
	for i in range(15):
		var local_x = rng.randf_range(-size/2, size/2)
		var local_z = rng.randf_range(-size/2, size/2)
		
		var global_x = offset_x + local_x
		var global_z = offset_z + local_z
		var noise_val = noise.get_noise_2d(global_x, global_z)
		
		var normalized_height = (noise_val + 1.0) / 2.0
		if normalized_height > 0.3 and normalized_height < 0.6:
			var h = noise_val * max_h
			
			var t = Transform3D()
			t = t.rotated(Vector3.UP, rng.randf_range(0, TAU))
			t = t.scaled(Vector3.ONE * rng.randf_range(0.8, 1.4))
			t.origin = Vector3(local_x, h, local_z)
			
			transforms.append(t)
			
	return transforms
