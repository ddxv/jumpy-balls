class_name ChunkPlatform
extends MeshInstance3D

const CENTER_OFFSET = 0.5
const RAMP_HEIGHT = 200

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

var my_multiplier = 0


func gen_platform(surftool: SurfaceTool, size: int, my_height: int, is_ramp: bool):
	var platform_width = roundi(size / float(4))
	var my_ramp_height = 0

	if is_ramp:
		my_ramp_height = RAMP_HEIGHT

	var vertices := PackedVector3Array(
		[
			# further end TOP SIDE 1,1
			Vector3(platform_width, my_height + my_ramp_height, -size),
			# TOP SIDE 0,1
			Vector3(-platform_width, my_height + my_ramp_height, -size),
			# Closer Right SIDE 0,0
			Vector3(-platform_width, my_height, 0),
			# Closer LEFT SIDE 1,0
			Vector3(platform_width, my_height, 0),
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
		surftool.set_uv(uvs[i])
		surftool.add_vertex(vertices[i])

	# Add indices
	for i in range(indices.size()):
		surftool.add_index(indices[i])

	return surftool


func generate_platforms(multiplier: int, coords: Vector2, size: int, initailly_visible: bool):
	if my_multiplier == 0 and multiplier > 0:
		my_multiplier = multiplier
	#set 2D position in world space
	grid_coord = coords
	var my_height = my_multiplier * RAMP_HEIGHT
	var my_height_2f = (my_multiplier * RAMP_HEIGHT) + RAMP_HEIGHT
	var my_height_3f = (my_multiplier * RAMP_HEIGHT) + RAMP_HEIGHT * 2
	var grid_coord_south = grid_coord + Vector2(0, 1)
	var grid_coord_south_south = grid_coord + Vector2(0, 2)
	# var grid_coord_south_south_south = grid_coord + Vector2(0, 3)
	position_coord = coords * size
	var a_mesh: ArrayMesh
	var surftool = SurfaceTool.new()
	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)
	#create Platfrom paths
	# print("try: mygrid", grid_coord, "south:", grid_coord_south)
	if int(grid_coord.x + grid_coord.y) % 4 == 0:
		surftool = gen_platform(surftool, size, my_height, true)
		surftool = gen_platform(surftool, size, my_height_3f, true)
	if int(grid_coord_south.x + grid_coord_south.y) % 4 == 0:
		surftool = gen_platform(surftool, size, my_height_2f, false)
		surftool = gen_platform(surftool, size, my_height_3f, false)
	if int(grid_coord_south_south.x + grid_coord_south_south.y) % 4 == 0:
		surftool = gen_platform(surftool, size, my_height_2f, true)
	# if int(grid_coord_south_south_south.x + grid_coord_south_south_south.y) % 4 == 0:
	#   surftool = gen_platform(surftool, size, RAMP_HEIGHT, false)
	# SECOND LEVEL OF PLATFORMS START
	# if int(grid_coord_south.x + grid_coord_south.y) % 4 == 0:
	# if int(grid_coord_south_south.x + grid_coord_south_south.y) % 4 == 0:
	# surftool = gen_platform(surftool, size, RAMP_HEIGHT*2, false)
	# if int(grid_coord_south_south_south.x + grid_coord_south_south_south.y) % 8 == 0:
	# surftool = gen_platform(surftool, size, RAMP_HEIGHT*2, false)

	#Generate Normal Map
	surftool.generate_normals()
	a_mesh = surftool.commit()
	mesh = a_mesh

	# Access the MeshInstance3D node
	# var mesh_instance = $MeshInstance3D

	# # Access the material override
	# var material = material_override
	# if material:
	# 	print("Material Override: ", material)
	# 	var current_albedo = material.albedo_color
	# 	print("Current Albedo Color: ", current_albedo)
	# 	# Set the albedo color to red
	# 	if multiplier == 0:
	# 		material.albedo_color = Color(1, 0, 0)  # RGB for red
	# 	elif multiplier == 1:
	# 		material.albedo_color = Color(0, 1, 0)  # RGB for red
	# 	elif multiplier == 2:
	# 		material.albedo_color = Color(0, 0, 1)  # RGB for red

	# # Access materials of individual surfaces
	# var num_surfaces = mesh.get_surface_count()
	# for i in range(num_surfaces):
	#       var material_1 = mesh.get_surface_material(i)
	#       print("Material of surface ", i, ": ", material_1)

	# var material = $MeshInstance3D.material_override
	# var material = MeshInstance3D.get_surface_material(0)
	# print("CHECK", material)

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
