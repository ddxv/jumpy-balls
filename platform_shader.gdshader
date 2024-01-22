shader_type spatial;

uniform sampler2D text_low;
uniform vec2 uvscale = vec2(1);

// Define colors
uniform vec3 green_color = vec3(0.0, 1.0, 0.0); // Green
uniform vec3 yellow_color = vec3(1.0, 1.0, 0.0); // Yellow
uniform vec3 red_color = vec3(1.0, 0.0, 0.0); // Red
uniform vec3 purple_color = vec3(0.5, 0.0, 0.5); // Purple

varying float vertex_y;

void vertex() {
    vertex_y = VERTEX.y;
}

void fragment() {
    vec3 tex_color = texture(text_low, UV * uvscale).rgb;

    // Determine color based on height
    vec3 my_color;
    if (vertex_y < 199.0) {
        my_color = green_color;
    } else if (vertex_y < 399.0) {
        my_color = yellow_color;
    } else if (vertex_y < 599.0) {
        my_color = red_color;
    } else {
        my_color = purple_color;
    }
    
    ALBEDO = my_color * tex_color;
}
