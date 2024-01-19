class_name ChunkPlatform
extends MeshInstance3D

const CENTER_OFFSET = 0.5

#Terrain size
@export_range(20, 400, 1) var terrain_size := 200
#LOD scaling
@export_range(1, 100, 1) var resolution := 20
@export var terrain_max_height = 5

@export var chunk_lods: Array[int] = [2, 4, 8, 15, 20, 50]
@export var lod_distances: Array[int] = [2000, 1500, 1050, 900, 790, 550]

#2D position in world space
var position_coord = Vector2()
var grid_coord = Vector2()

var set_collision = false


func gen_platform(surftool: SurfaceTool, size: int, my_height: int):
	var platform_size = size / 4
	var south_length = 400
	var ramp_height = 200
	var vertices := PackedVector3Array(
		[
			# TOP NORTH SIDE, 0,1
			#Vector3(-platform_size, my_height + ramp_height, -platform_size - ramp_height * 2),
			# TOP NORTH SIDE, 1,1
			#Vector3(platform_size, my_height + ramp_height, -platform_size - ramp_height * 2),
			# SOUTH TOP SIDE 1,1
			Vector3(platform_size, my_height, platform_size),
			# SOUTH TOP SIDE 0,1
			Vector3(-platform_size, my_height, platform_size),
			# SOUTH+LOWER SIDE 0,0
			Vector3(-platform_size, my_height - ramp_height, platform_size + south_length),
			# SOUTH+LOWER LEFT SIDE 1,0
			Vector3(platform_size, my_height - ramp_height, platform_size + south_length),
		]
	)

	var uvs := PackedVector2Array(
		[
			Vector2(1, 1),
			Vector2(1, 0),
			Vector2(0, 0),
			Vector2(0, 1),
		]
	)

	var indices := PackedInt32Array(
		[
			# SOUTH SIDE (right triangle, then left)
			0,
			2,
			1,
			2,
			0,
			3
		]
	)
	# Add each vertex and UV coordinate
	for i in range(vertices.size()):
		print("i", i, "and uv", uvs[i])
		surftool.set_uv(uvs[i])
		surftool.add_vertex(vertices[i])

	# Add indices
	for i in range(indices.size()):
		surftool.add_index(indices[i])

	return surftool


func generate_platforms(my_height: int, coords: Vector2, size: float, initailly_visible: bool):
	terrain_size = size
	#set 2D position in world space
	grid_coord = coords
	position_coord = coords * size
	var a_mesh: ArrayMesh
	var surftool = SurfaceTool.new()
	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)
	#create Array Mesh from Data
	if int(grid_coord.x + grid_coord.y) % 2 == 0:
		surftool = gen_platform(surftool, size, my_height + 50)
	if int(grid_coord.x + grid_coord.y) % 6 == 0:
		surftool = gen_platform(surftool, size / 2, my_height + 200)
	if int(grid_coord.x + grid_coord.y) % 8 == 0:
		surftool = gen_platform(surftool, size / 4, my_height + 400)
	if int(grid_coord.x + grid_coord.y) % 8 == 0:
		surftool = gen_platform(surftool, size / 4, my_height + 600)
	if int(grid_coord.x + grid_coord.y) % 8 == 0:
		surftool = gen_platform(surftool, size / 4, my_height + 1000)
	#Generate Normal Map
	surftool.generate_normals()
	a_mesh = surftool.commit()
	mesh = a_mesh
	if set_collision:
		create_collision()
	#set to invisible on start
	set_chunk_visible(initailly_visible)


#create collision
func create_collision():
	if get_child_count() > 0:
		get_child(0).queue_free()
	create_trimesh_collision()


#SLOW
func should_remove(view_pos: Vector2):
	var remove = false
	var viewer_distance = position_coord.distance_to(view_pos)
	if viewer_distance > Globals.VIEW_DISTANCE * 1.1:
		remove = true
	return remove


#update mesh based on distance
func update_lod(view_pos: Vector2):
	var viewer_distance = position_coord.distance_to(view_pos)
	var update_terrain = false
	var new_lod = chunk_lods[0]
	if chunk_lods.size() != lod_distances.size():
		print("ERROR Lods and Distance count mismatch")
		return
	for i in range(chunk_lods.size()):
		var lod = chunk_lods[i]
		var dis = lod_distances[i]
		if viewer_distance < dis:
			new_lod = lod
	#if terrain is at highest detail create collision shape
	if new_lod >= chunk_lods[chunk_lods.size() - 1]:
		set_collision = true
	else:
		set_collision = false
	# if resolution is not equal to new resolution
	#set update terrain to true
	if resolution != new_lod:
		resolution = new_lod
		update_terrain = true
	return update_terrain


#remove chunk
func free_chunk():
	queue_free()


#set chunk visibility
func set_chunk_visible(_is_visible):
	visible = _is_visible


#get chunk visible
func get_chunk_visible():
	return visible
