extends Node3D

# Export variables for tiling control
@export var wall_tiling: float = 1.0
@export var floor_tiling: float = 3.0
@export var ceiling_tiling: float = 3.0
@export var height_scale: float = 0.01

# Reference to the material resource
@export var material_resource: ShaderMaterial

var mesh_instance: MeshInstance3D

func _ready():
	# Create a cube mesh
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = Vector3(1, 1, 1)
	
	# Create a MeshInstance3D node
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = cube_mesh
	add_child(mesh_instance)
	
	# Add collision
	var static_body = StaticBody3D.new()
	add_child(static_body)
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)
	collision_shape.shape = box_shape
	static_body.add_child(collision_shape)
	
	# Set up the material
	if material_resource == null:
		# Create a ShaderMaterial
		material_resource = ShaderMaterial.new()
		material_resource.shader = load("res://wall_shader.gdshader")
		
		# Load all textures
		_load_textures()
	
	# Apply the material to the mesh
	mesh_instance.material_override = material_resource
	
	# Set the tiling parameters
	_update_material_parameters()

func _load_textures():
	# Load wall textures
	var wall_diffuse = load("res://textures/wall_1/wall_diffuse.bmp")
	var wall_edge = load("res://textures/wall_1/wall_edge.bmp")
	var wall_height = load("res://textures/wall_1/wall_height.bmp")
	var wall_metallic = load("res://textures/wall_1/wall_metallic.bmp")
	var wall_normal = load("res://textures/wall_1/wall_normal.bmp")
	var wall_smoothness = load("res://textures/wall_1/wall_smoothness.bmp")
	
	# Load floor textures
	var floor_diffuse = load("res://textures/floor_1/floor_diffuse.bmp")
	var floor_edge = load("res://textures/floor_1/floor_edge.bmp")
	var floor_height = load("res://textures/floor_1/floor_height.bmp")
	var floor_metallic = load("res://textures/floor_1/floor_metallic.bmp")
	var floor_normal = load("res://textures/floor_1/floor_normal.bmp")
	var floor_smoothness = load("res://textures/floor_1/floor_smoothness.bmp")
	
	# Load ceiling textures
	var ceiling_diffuse = load("res://textures/ceiling_1/ceiling_diffuse.bmp")
	var ceiling_edge = load("res://textures/ceiling_1/ceiling_edge.bmp")
	var ceiling_height = load("res://textures/ceiling_1/ceiling_height.bmp")
	var ceiling_metallic = load("res://textures/ceiling_1/ceiling_metallic.bmp")
	var ceiling_normal = load("res://textures/ceiling_1/ceiling_normal.bmp")
	var ceiling_smoothness = load("res://textures/ceiling_1/ceiling_smoothness.bmp")
	
	# Set shader parameters for wall textures
	material_resource.set_shader_parameter("wall_diffuse", wall_diffuse)
	material_resource.set_shader_parameter("wall_edge", wall_edge)
	material_resource.set_shader_parameter("wall_height", wall_height)
	material_resource.set_shader_parameter("wall_metallic", wall_metallic)
	material_resource.set_shader_parameter("wall_normal", wall_normal)
	material_resource.set_shader_parameter("wall_smoothness", wall_smoothness)
	
	# Set shader parameters for floor textures
	material_resource.set_shader_parameter("floor_diffuse", floor_diffuse)
	material_resource.set_shader_parameter("floor_edge", floor_edge)
	material_resource.set_shader_parameter("floor_height", floor_height)
	material_resource.set_shader_parameter("floor_metallic", floor_metallic)
	material_resource.set_shader_parameter("floor_normal", floor_normal)
	material_resource.set_shader_parameter("floor_smoothness", floor_smoothness)
	
	# Set shader parameters for ceiling textures
	material_resource.set_shader_parameter("ceiling_diffuse", ceiling_diffuse)
	material_resource.set_shader_parameter("ceiling_edge", ceiling_edge)
	material_resource.set_shader_parameter("ceiling_height", ceiling_height)
	material_resource.set_shader_parameter("ceiling_metallic", ceiling_metallic)
	material_resource.set_shader_parameter("ceiling_normal", ceiling_normal)
	material_resource.set_shader_parameter("ceiling_smoothness", ceiling_smoothness)

func _update_material_parameters():
	# Set the tiling parameters
	material_resource.set_shader_parameter("wall_tiling", wall_tiling)
	material_resource.set_shader_parameter("floor_tiling", floor_tiling)
	material_resource.set_shader_parameter("ceiling_tiling", ceiling_tiling)
	material_resource.set_shader_parameter("height_scale", height_scale)
