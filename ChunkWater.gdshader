shader_type spatial;

uniform sampler2D terrain_water;

varying float vertex_y;
uniform vec2 uvscale = vec2(1);

void fragment() {
	float vert_weight = vertex_y;
	
	vec3 grass = texture(terrain_water,UV*uvscale).rgb;
	
	ALBEDO = grass.rgb;

	
}
void vertex(){
	vertex_y = VERTEX.y;
}


//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
