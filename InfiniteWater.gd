extends Node3D

@export var viewer: Node3D
@export var chunk_mesh_scene: PackedScene

# @export var chunk_size = 100
@export var terrain_height = 20
@export var render_debug := false

var terrain_chunks = {}
var chunksvisible: int = 0

var viewer_position = Vector2()
var last_visible_chunks = []


func _ready():
	#set the total chunks to be visible
	chunksvisible = roundi(Globals.VIEW_DISTANCE / float(Globals.CHUNK_SIZE))
	viewer = viewer.get_node("MyBall")
	if render_debug:
		set_wireframe()
	update_visible_chunk()


func set_wireframe():
	RenderingServer.set_debug_generate_wireframes(true)
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME


func _process(_delta):
	viewer_position.x = viewer.global_position.x
	viewer_position.y = viewer.global_position.z
	update_visible_chunk()


func update_visible_chunk():
	#hide chunks that were are out of view
#	for chunk in last_visible_chunks:
#		chunk.setChunkVisible(false)
#	last_visible_chunks.clear()
	#get grid position
	var current_x = roundi(viewer_position.x / Globals.CHUNK_SIZE)
	var current_y = roundi(viewer_position.y / Globals.CHUNK_SIZE)
	#get all the chunks within visiblity range
	for y_offset in range(0, chunksvisible):
		for x_offset in range(-chunksvisible, chunksvisible):
			#create a new chunk coordinate
			var view_chunk_coord = Vector2(current_x - x_offset, current_y - y_offset)
			#check if chunk was already created
			if terrain_chunks.has(view_chunk_coord):
				# var ref = weakref(terrain_chunks[view_chunk_coord])
				#if chunk exist update the chunk passing viewer_position and view_distance
				# terrain_chunks[view_chunk_coord].update_chunk(viewer_position, view_distance)
				if terrain_chunks[view_chunk_coord].update_lod(viewer_position):
					terrain_chunks[view_chunk_coord].generate_water(
						view_chunk_coord, Globals.CHUNK_SIZE, true
					)
				#if chunk is visible add it to last visible chunks
#				if terrain_chunks[view_chunk_coord].getChunkVisible():
#					last_visible_chunks.append(terrain_chunks[view_chunk_coord])
			else:
				#print(view_chunk_coord)
				#if chunk doesnt exist, create chunk
				var chunk: ChunkWater = chunk_mesh_scene.instantiate()
				add_child(chunk)
				#set chunk parameters
				chunk.terrain_max_height = terrain_height
				#set chunk world position
				var pos = view_chunk_coord * Globals.CHUNK_SIZE
				var world_position = Vector3(pos.x, 0, pos.y)
				chunk.global_position = world_position
				chunk.generate_water(view_chunk_coord, Globals.CHUNK_SIZE, false)
				terrain_chunks[view_chunk_coord] = chunk
#check if we should remove chunk from scene
	for chunk in get_children():
		if chunk.should_remove(viewer_position):
			chunk.queue_free()
			if terrain_chunks.has(chunk.grid_coord):
				terrain_chunks.erase(chunk.grid_coord)


func get_active_threads():
	#This version isnt using
	#threading so return 0
	return 0
