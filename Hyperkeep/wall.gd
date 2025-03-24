extends MeshInstance3D

@export var wall_tiling: float = 3.0
@export var floor_tiling: float = 3.0
@export var ceiling_tiling: float = 3.0
@export var height_scale: float = 0.01

# Reference to the material resource
@export var material_resource: ShaderMaterial

func _ready():
	# If no material is assigned, create a new one
	if material_resource == null:
		material_resource = ShaderMaterial.new()
		material_resource.shader = load("res://wall_shader.gdshader")
		
		# Load all textures
		_load_textures()
	
	# Apply the material to the mesh
	material_override = material_resource
	
	# Set the tiling parameters
	_update_material_parameters()

func _load_textures():
	# Wall textures
	material_resource.set_shader_parameter("wall_diffuse", load("res://textures/wall_1/wall_diffuse.bmp"))
	material_resource.set_shader_parameter("wall_edge", load("res://textures/wall_1/wall_edge.bmp"))
	material_resource.set_shader_parameter("wall_height", load("res://textures/wall_1/wall_height.bmp"))
	material_resource.set_shader_parameter("wall_metallic", load("res://textures/wall_1/wall_metallic.bmp"))
	material_resource.set_shader_parameter("wall_normal", load("res://textures/wall_1/wall_normal.bmp"))
	material_resource.set_shader_parameter("wall_smoothness", load("res://textures/wall_1/wall_smoothness.bmp"))
	
	# Floor textures
	material_resource.set_shader_parameter("floor_diffuse", load("res://textures/floor_1/floor_diffuse.bmp"))
	material_resource.set_shader_parameter("floor_edge", load("res://textures/floor_1/floor_edge.bmp"))
	material_resource.set_shader_parameter("floor_height", load("res://textures/floor_1/floor_height.bmp"))
	material_resource.set_shader_parameter("floor_metallic", load("res://textures/floor_1/floor_metallic.bmp"))
	material_resource.set_shader_parameter("floor_normal", load("res://textures/floor_1/floor_normal.bmp"))
	material_resource.set_shader_parameter("floor_smoothness", load("res://textures/floor_1/floor_smoothness.bmp"))
	
	# Ceiling textures
	material_resource.set_shader_parameter("ceiling_diffuse", load("res://textures/ceiling_1/ceiling_diffuse.bmp"))
	material_resource.set_shader_parameter("ceiling_edge", load("res://textures/ceiling_1/ceiling_edge.bmp"))
	material_resource.set_shader_parameter("ceiling_height", load("res://textures/ceiling_1/ceiling_height.bmp"))
	material_resource.set_shader_parameter("ceiling_metallic", load("res://textures/ceiling_1/ceiling_metallic.bmp"))
	material_resource.set_shader_parameter("ceiling_normal", load("res://textures/ceiling_1/ceiling_normal.bmp"))
	material_resource.set_shader_parameter("ceiling_smoothness", load("res://textures/ceiling_1/ceiling_smoothness.bmp"))

func _update_material_parameters():
	# Set the tiling parameters
	material_resource.set_shader_parameter("wall_tiling", wall_tiling)
	material_resource.set_shader_parameter("floor_tiling", floor_tiling)
	material_resource.set_shader_parameter("ceiling_tiling", ceiling_tiling)
	material_resource.set_shader_parameter("height_scale", height_scale)

# This function can be called to update the tiling at runtime if needed
func set_tiling(wall: float, floor_tile: float, ceiling: float):
	wall_tiling = wall
	floor_tiling = floor_tile
	ceiling_tiling = ceiling
	_update_material_parameters()
