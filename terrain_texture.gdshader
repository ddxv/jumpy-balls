shader_type spatial;

uniform sampler2D terrain_grass;
uniform sampler2D terrain_lava;
uniform float min_grass_height = -40.0;
//uniform float max_rock_height = 5.0;
uniform float min_lava_height = -50.0;
varying float vertex_y;
uniform vec2 uvscale = vec2(1);
void fragment() {
	float vert_weight = vertex_y;
	
	vec3 grass = texture(terrain_grass,UV*uvscale).rgb;
	vec3 lava = texture(terrain_lava,UV*uvscale).rgb;
	
	float weight = smoothstep(min_lava_height,min_grass_height,vert_weight);
	vec3 final_color = mix(lava,grass,weight);
	
	ALBEDO = grass.rgb;

	
}
void vertex(){
	vertex_y = VERTEX.y;
}
