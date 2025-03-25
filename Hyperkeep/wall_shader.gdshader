shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

// Tiling controls for each texture type
uniform float wall_tiling : hint_range(0.1, 10.0) = 3.0;
uniform float floor_tiling : hint_range(0.1, 10.0) = 1.0;
uniform float ceiling_tiling : hint_range(0.1, 10.0) = 1.0;

// Wall textures
uniform sampler2D wall_diffuse : source_color;
uniform sampler2D wall_edge : hint_default_white;
uniform sampler2D wall_height;
uniform sampler2D wall_metallic : hint_default_black;
uniform sampler2D wall_normal : hint_normal;
uniform sampler2D wall_smoothness : hint_default_white;

// Floor textures
uniform sampler2D floor_diffuse : source_color;
uniform sampler2D floor_edge : hint_default_white;
uniform sampler2D floor_height;
uniform sampler2D floor_metallic : hint_default_black;
uniform sampler2D floor_normal : hint_normal;
uniform sampler2D floor_smoothness : hint_default_white;

// Ceiling textures
uniform sampler2D ceiling_diffuse : source_color;
uniform sampler2D ceiling_edge : hint_default_white;
uniform sampler2D ceiling_height;
uniform sampler2D ceiling_metallic : hint_default_black;
uniform sampler2D ceiling_normal : hint_normal;
uniform sampler2D ceiling_smoothness : hint_default_white;

// Height map intensity
uniform float height_scale : hint_range(0.0, 0.05) = 0.01;

void fragment() {
    // Get the world position of the fragment
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Determine which face we're on based on NORMAL in world space
    vec3 world_normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    
    vec2 tiled_uv;
    
    if (abs(world_normal.y) > 0.7) {
        // Top or bottom face
        if (world_normal.y > 0.0) {
            // Top face (floor)
            // Use world position to create continuous UVs for seamless tiling
            tiled_uv = world_pos.xz * floor_tiling;
            ALBEDO = texture(floor_diffuse, tiled_uv).rgb;
            METALLIC = texture(floor_metallic, tiled_uv).r * 0.3;
            ROUGHNESS = 1.0 - (texture(floor_smoothness, tiled_uv).r * 0.8);
            NORMAL_MAP = texture(floor_normal, tiled_uv).rgb;
            float edge = texture(floor_edge, tiled_uv).r;
            ALBEDO = mix(ALBEDO, ALBEDO * 1.2, edge);
            float height = texture(floor_height, tiled_uv).r;
            NORMAL_MAP_DEPTH = height_scale * 10.0;
        } else {
            // Bottom face (ceiling)
            tiled_uv = UV * ceiling_tiling;
            ALBEDO = texture(ceiling_diffuse, tiled_uv).rgb;
            METALLIC = texture(ceiling_metallic, tiled_uv).r * 0.3;
            ROUGHNESS = 1.0 - (texture(ceiling_smoothness, tiled_uv).r * 0.8);
            NORMAL_MAP = texture(ceiling_normal, tiled_uv).rgb;
            float edge = texture(ceiling_edge, tiled_uv).r;
            ALBEDO = mix(ALBEDO, ALBEDO * 1.2, edge);
            float height = texture(ceiling_height, tiled_uv).r;
            NORMAL_MAP_DEPTH = height_scale * 10.0;
        }
    } else {
        // Side faces (walls)
        // Use world position to create continuous UVs
        if (abs(world_normal.x) > 0.7) {
            // X-facing faces (left or right)
            tiled_uv = vec2(world_pos.z, world_pos.y) * wall_tiling;
        } else {
            // Z-facing faces (front or back)
            tiled_uv = vec2(world_pos.x, world_pos.y) * wall_tiling;
        }
        
        // Apply wall textures
        ALBEDO = texture(wall_diffuse, tiled_uv).rgb;
        METALLIC = texture(wall_metallic, tiled_uv).r * 0.3;
        ROUGHNESS = 1.0 - (texture(wall_smoothness, tiled_uv).r * 0.8);
        NORMAL_MAP = texture(wall_normal, tiled_uv).rgb;
        
        // Use edge map for edge highlighting or as a mask
        float edge = texture(wall_edge, tiled_uv).r;
        ALBEDO = mix(ALBEDO, ALBEDO * 1.2, edge);
        
        // Apply height map effect
        float height = texture(wall_height, tiled_uv).r;
        NORMAL_MAP_DEPTH = height_scale * 10.0;
    }
}