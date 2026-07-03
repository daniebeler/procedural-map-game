extends Node3D

@export var target_node: Node3D
@export var terrain_colors: Gradient
@export var tree_mesh: Mesh
@export var tree_material: Material

@export var chunk_size: float = 32.0
@export var chunk_resolution: int = 32
@export var max_height: float = 10.0
@export var render_distance: int = 4

var generator: ChunkGenerator
var scatterer: FoliageScatterer

var active_chunks := {}
var current_chunk_coord := Vector2i(9999, 9999)

var completed_chunks := {}
var chunks_in_progress := []
var mutex := Mutex.new()

func _ready() -> void:
	var world_seed = randi()
	generator = ChunkGenerator.new(world_seed)
	scatterer = FoliageScatterer.new()

func _process(_delta: float) -> void:
	var chunks_to_spawn := {}
	
	mutex.lock()
	if not completed_chunks.is_empty():
		chunks_to_spawn = completed_chunks.duplicate()
		completed_chunks.clear()
	mutex.unlock()
	
	for coord in chunks_to_spawn:
		chunks_in_progress.erase(coord)
		var distance = (coord - current_chunk_coord).length()
		if distance <= render_distance + 1:
			spawn_chunk_node(coord, chunks_to_spawn[coord])

	if not target_node: return
		
	var target_chunk_x = floor(target_node.global_position.x / chunk_size)
	var target_chunk_z = floor(target_node.global_position.z / chunk_size)
	var new_coord = Vector2i(target_chunk_x, target_chunk_z)
	
	if new_coord != current_chunk_coord:
		current_chunk_coord = new_coord
		update_chunks()

func update_chunks() -> void:
	var chunks_to_keep := []
	
	for x in range(-render_distance, render_distance + 1):
		for z in range(-render_distance, render_distance + 1):
			var chunk_coord = current_chunk_coord + Vector2i(x, z)
			chunks_to_keep.append(chunk_coord)
			
			if not active_chunks.has(chunk_coord) and not chunk_coord in chunks_in_progress:
				chunks_in_progress.append(chunk_coord)
				WorkerThreadPool.add_task(_bg_generate_data.bind(chunk_coord))
				
	for coord in active_chunks.keys():
		if not coord in chunks_to_keep:
			active_chunks[coord].queue_free()
			active_chunks.erase(coord)

# ─── THREADED WORK ───
func _bg_generate_data(coord: Vector2i) -> void:
	var mesh = generator.generate_mesh(coord, chunk_size, chunk_resolution, max_height, terrain_colors)
	var trees = scatterer.get_tree_transforms(coord, chunk_size, generator.noise, max_height)
	
	mutex.lock()
	# Pass a dictionary back containing both pieces of data
	completed_chunks[coord] = { "mesh": mesh, "trees": trees }
	mutex.unlock()

# ─── MAIN THREAD SPAWNING ───
func spawn_chunk_node(coord: Vector2i, data: Dictionary) -> void:
	var chunk_root := Node3D.new()
	
	var chunk_world_x = coord.x * chunk_size
	var chunk_world_z = coord.y * chunk_size
	chunk_root.position = Vector3(chunk_world_x, 0, chunk_world_z)
	
	var ground := MeshInstance3D.new()
	ground.mesh = data["mesh"]
	
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 0.85
	ground.set_material_override(mat)
	
	chunk_root.add_child(ground)
	ground.create_trimesh_collision()
	
	# Setup trees
	if tree_mesh and data["trees"].size() > 0:
		var tree_transforms: Array[Transform3D] = data["trees"]
		
		var m_mesh := MultiMesh.new()
		m_mesh.transform_format = MultiMesh.TRANSFORM_3D
		m_mesh.instance_count = tree_transforms.size()
		m_mesh.mesh = tree_mesh
		
		for i in range(tree_transforms.size()):
			m_mesh.set_instance_transform(i, tree_transforms[i])
			
		var tree_instance := MultiMeshInstance3D.new()
		tree_instance.multimesh = m_mesh
		if tree_material:
			tree_instance.set_material_override(tree_material)
		chunk_root.add_child(tree_instance)
		
	add_child(chunk_root)
	active_chunks[coord] = chunk_root
