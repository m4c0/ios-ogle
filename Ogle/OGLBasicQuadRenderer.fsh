//
//  OGLBasicQuadRenderer.fsh
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 10/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

#extension GL_EXT_shader_framebuffer_fetch : require

uniform sampler2D us_texture;

varying lowp vec2 vv2_tex;
varying lowp float vf_dim;

void main() {
    lowp vec4 lv4_lastFrag = gl_LastFragData[0];
    lowp vec4 lv4_color = texture2D(us_texture, vv2_tex) * vf_dim;
    gl_FragColor = mix(lv4_lastFrag, lv4_color, lv4_color.a);
}
