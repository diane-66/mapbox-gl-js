#define SDF_PX 8.0

uniform bool u_is_halo;
uniform sampler2D u_texture;
uniform highp float u_gamma_scale;
uniform lowp float u_device_pixel_ratio;
uniform bool u_is_text;

varying vec2 v_data0;
varying vec3 v_data1;

#ifdef FOG
varying vec3 v_fog_pos;
#endif


#pragma mapbox: define highp vec4 fill_color
#pragma mapbox: define highp vec4 halo_color
#pragma mapbox: define lowp float opacity
#pragma mapbox: define lowp float halo_width
#pragma mapbox: define lowp float halo_blur

void main() {
    #pragma mapbox: initialize highp vec4 fill_color
    #pragma mapbox: initialize highp vec4 halo_color
    #pragma mapbox: initialize lowp float opacity
    #pragma mapbox: initialize lowp float halo_width
    #pragma mapbox: initialize lowp float halo_blur

    float EDGE_GAMMA = 0.105 / u_device_pixel_ratio;

    vec2 tex = v_data0.xy;
    float gamma_scale = v_data1.x;
    float size = v_data1.y;
    float fade_opacity = v_data1[2];

    float fontScale = u_is_text ? size / 24.0 : size;

    lowp vec4 color = fill_color;
    highp float gamma = EDGE_GAMMA / (fontScale * u_gamma_scale);
    lowp float buff = (256.0 - 64.0) / 256.0;

    float fog_alpha = 1.0;
    #ifdef FOG
        fog_alpha = 1.0 - fog_opacity(v_fog_pos);
    #endif

    if (u_is_halo) {
        color = halo_color * fog_alpha;
        gamma = (halo_blur * fog_alpha * 1.19 / SDF_PX + EDGE_GAMMA) / (fontScale * u_gamma_scale);
        buff = (6.0 - (halo_width * fog_alpha) / fontScale) / SDF_PX;
    }

    lowp float dist = texture2D(u_texture, tex).a;
    highp float gamma_scaled = gamma * gamma_scale;
    highp float alpha = smoothstep(buff - gamma_scaled, buff + gamma_scaled, dist);

    vec4 out_color = color;


    gl_FragColor = out_color * (alpha * opacity * fade_opacity * fog_alpha);

#ifdef OVERDRAW_INSPECTOR
    gl_FragColor = vec4(1.0);
#endif
}
