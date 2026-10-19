shader_type canvas_item;

uniform sampler2D mask_texture: source_color;

void fragment(){
    //vec4 color = texture(TEXTURE, UV);
    vec4 color = COLOR;
    vec4 mask = texture(mask_texture, UV);
    color.a *= (1.0 - mask.r);
    COLOR = color;
}