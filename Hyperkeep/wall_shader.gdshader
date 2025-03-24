shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

// Tiling controls for each texture type
uniform float wall_tiling : hint_range(0.1, 10.0) = 1.0;
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
    // Get the base UV coordinates
    vec2 base_uv = UV;
    
    // Determine which face we're on based on NORMAL in world space
    vec3 world_normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    
    if (abs(world_normal.y) > 0.7) {
        // Top or bottom face
        if (world_normal.y > 0.0) {
            // Top face (floor)
            // Apply tiling to UVs
            vec2 tiled_uv = base_uv * floor_tiling;
            
            // Apply floor textures
            ALBEDO = texture(floor_diffuse, tiled_uv).rgb;
            METALLIC = texture(floor_metallic, tiled_uv).r;
            ROUGHNESS = 1.0 - texture(floor_smoothness, tiled_uv).r;
            NORMAL_MAP = texture(floor_normal, tiled_uv).rgb;
            
            // Use edge map for edge highlighting or as a mask
            float edge = texture(floor_edge, tiled_uv).r;
            ALBEDO = mix(ALBEDO, ALBEDO * 1.2, edge);
            
            // Apply height map effect
            float height = texture(floor_height, tiled_uv).r;
            NORMAL_MAP_DEPTH = height_scale * 10.0;
        } else {
            // Bottom face (ceiling)
            // Apply tiling to UVs
            vec2 tiled_uv = base_uv * ceiling_tiling;
            
            // Apply ceiling textures
            ALBEDO = texture(ceiling_diffuse, tiled_uv).rgb;
            METALLIC = texture(ceiling_metallic, tiled_uv).r;
            ROUGHNESS = 1.0 - texture(ceiling_smoothness, tiled_uv).r;
            NORMAL_MAP = texture(ceiling_normal, tiled_uv).rgb;
            
            // Use edge map for edge highlighting or as a mask
            float edge = texture(ceiling_edge, tiled_uv).r;
            ALBEDO = mix(ALBEDO, ALBEDO * 1.2, edge);
            
            // Apply height map effect
            float height = texture(ceiling_height, tiled_uv).r;
            NORMAL_MAP_DEPTH = height_scale * 10.0;
        }
    } else {
        // Side faces (walls)
        // Apply tiling to UVs
        vec2 tiled_uv = base_uv * wall_tiling;
        
        // Apply wall textures
        ALBEDO = texture(wall_diffuse, tiled_uv).rgb;
        METALLIC = texture(wall_metallic, tiled_uv).r;
        ROUGHNESS = 1.0 - texture(wall_smoothness, tiled_uv).r;
        NORMAL_MAP = texture(wall_normal, tiled_uv).rgb;
        
        // Use edge map for edge highlighting or as a mask
        float edge = texture(wall_edge, tiled_uv).r;
        ALBEDO = mix(ALBEDO, ALBEDO * 1.2, edge);
        
        // Apply height map effect
        float height = texture(wall_height, tiled_uv).r;
        NORMAL_MAP_DEPTH = height_scale * 10.0;
    }
}

