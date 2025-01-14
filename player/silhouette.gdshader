shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture;
uniform vec4 silouhette_color: source_color = vec4(0.0, 1.0, 0.0, 0.5);
uniform bool is_night = true;
//render_mode blend_mix;

void fragment() {
	

	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	vec4 sprite_color = texture(TEXTURE, UV);
	if(all(lessThan(abs(sprite_color.rgb - screen_color.rgb), vec3(0.01)))) {
		COLOR = COLOR;
		//COLOR = vec4(sprite_color.rgb, 1.0);
	} else {
		COLOR = vec4(silouhette_color.rgb, silouhette_color.a * sprite_color.a);
		//COLOR = screen_color;
	}
}


