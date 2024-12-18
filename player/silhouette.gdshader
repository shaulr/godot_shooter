shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture;
uniform vec4 silouhette_color: source_color = vec4(0.0, 0.0, 0.0, 0.5);

void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	vec4 sprite_color = texture(TEXTURE, UV);
	if(all(lessThan(abs(sprite_color.rgb - screen_color.rgb), vec3(0.1)))) {
		//COLOR = sprite_color;
		COLOR = vec4(sprite_color.rgb, 1.0);
	} else {
		COLOR = vec4(silouhette_color.rgb, silouhette_color.a * sprite_color.a);
	} 
}

