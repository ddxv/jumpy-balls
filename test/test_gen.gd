@tool
extends MeshInstance3D

@export var x_size = 20
@export var z_size = 20

@export var update = false
@export var clear_vert_vis = false


func _ready():
	generate_terrain()


func generate_terrain():
	var a_mesh: ArrayMesh
	var surftool = SurfaceTool.new()

	var n = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_PERLIN
	n.frequency = 0.1

	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in range(z_size + 1):
		for x in range(x_size + 1):
			var y = n.get_noise_2d(x, z) * 5
			var mypos = Vector3(x, y, z)
			var uv = Vector2()
			uv.x = inverse_lerp(0, x_size, x)
			uv.y = inverse_lerp(0, z_size, z)
			surftool.set_uv(uv)
			surftool.add_vertex(mypos)
			draw_sphere(mypos)

	var vert = 0
	for z in z_size:
		for x in x_size:
			surftool.add_index(vert + 0)
			surftool.add_index(vert + 1)
			surftool.add_index(vert + x_size + 1)
			surftool.add_index(vert + x_size + 1)
			surftool.add_index(vert + 1)
			surftool.add_index(vert + x_size + 2)
			vert += 1
		vert += 1

	surftool.generate_normals()

	a_mesh = surftool.commit()
	mesh = a_mesh


func draw_sphere(pos: Vector3):
	var ins = MeshInstance3D.new()
	add_child(ins)
	ins.position = pos
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	ins.mesh = sphere


func _process(_delta):
	if update:
		generate_terrain()
		update = false
	if clear_vert_vis:
		for i in get_children():
			i.free()
