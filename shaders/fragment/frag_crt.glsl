


#define PI 3.14159265359

uniform float window_width;
uniform float window_scale;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
	vec2 coords = texture_coords;
	float c = 0.2;
	float line_period = 0.015;
	float line_width = 0.15;

	vec4 col = color;
	float cr, cg, cb, ca;
	cr = color.r; cg = color.g; cb = color.b; ca = color.a;

	vec2 dir, dirv;
	dir.xy = vec2(1.0, 0.0)/(window_width*window_scale);
	dirv.xy = vec2(0.0, 1.0)/(window_width*window_scale);
	
	// curvature of the screen
	float tx = texture_coords.x - 0.5;
	float ty = texture_coords.y - 0.5;

	float stretchx = tx*(ty * ty * c);
	float stretchy = ty*(tx * tx * c);
	coords.x += stretchx;
	coords.y += stretchy;

	// scan lines
	float line_intensity = 0.3;
	float frequency = 480;

	col.rgb += (line_intensity - line_intensity * sin(frequency * PI * coords.y)) * (1 - abs(tx * tx)) * (1 - abs(ty * ty)) + line_intensity/4;

	//vignette
	col -= abs(tx * tx * tx)*2;
	col -= abs(ty * ty * ty)*2;

	// horizontal blur
    vec4 tex_col = Texel(tex, coords);
	tex_col += Texel(tex, coords + dir)*0.5;
	tex_col += Texel(tex, coords - dir)*0.5;
	tex_col += Texel(tex, coords + dirv)*1;
	tex_col += Texel(tex, coords - dirv)*1;
	tex_col /= 4;

    return tex_col * col;
}