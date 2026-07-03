extends RefCounted
class_name ChunkGenerator

var noise := FastNoiseLite.new()

func _init(world_seed: int) -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = world_seed
	noise.frequency = 0.015
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	noise.fractal_gain = 0.3

func generate_mesh(coord: Vector2i, size: float, resolution: int, max_h: float, gradient: Gradient) -> Mesh:
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(size, size)
	plane_mesh.subdivide_width = resolution
	plane_mesh.subdivide_depth = resolution
	
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_mesh.get_mesh_arrays())
	
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)
	
	var offset_x = coord.x * size
	var offset_z = coord.y * size
	
	for i in range(mdt.get_vertex_count()):
		var vertex := mdt.get_vertex(i)
		var global_x = vertex.x + offset_x
		var global_z = vertex.z + offset_z
		
		var noise_val = noise.get_noise_2d(global_x, global_z)
		vertex.y = noise_val * max_h
		mdt.set_vertex(i, vertex)
		
		if gradient:
			var normalized_height = (noise_val + 1.0) / 2.0
			mdt.set_vertex_color(i, gradient.sample(normalized_height))
			
	array_mesh.clear_surfaces()
	mdt.commit_to_surface(array_mesh)
	
	var st := SurfaceTool.new()
	st.create_from(array_mesh, 0)
	st.generate_normals()
	return st.commit()
