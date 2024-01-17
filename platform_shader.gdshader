shader_type spatial;

uniform sampler2D text_low;
uniform sampler2D text_high;
uniform float low_height = -40.0;
uniform float max_height = 800.0;
varying float vertex_y;
uniform vec2 uvscale = vec2(5);
void fragment() {
	float vert_weight = vertex_y;
	
	vec3 lowplatform = texture(text_low,UV*uvscale).rgb;
	vec3 highplatform = texture(text_high,UV*uvscale).rgb;
	
	float weight = smoothstep(max_height,low_height,vert_weight);
	vec3 final_color = mix(lowplatform,highplatform,weight);
	
	ALBEDO = final_color.rgb;
	//ALBEDO = lava_color;
	
}
void vertex(){
	vertex_y = VERTEX.y;
}
