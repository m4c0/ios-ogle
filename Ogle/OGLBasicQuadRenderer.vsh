//
//  OGLBasicQuadRenderer.vsh
//  Ogle
//
//  Created by Eduardo Mauricio da Costa on 10/12/14.
//  Copyright (c) 2014 Eduardo Mauricio da Costa. All rights reserved.
//

uniform vec2 uv2_position;
uniform vec4 uv4_scale;

attribute vec2 av2_pos;
attribute vec2 av2_tex;
attribute vec4 av4_pos;
attribute vec4 av4_tex;
attribute vec4 av4_rot;
attribute vec4 av4_pickerColor;
attribute vec2 av2_scale;
attribute float af_dim;

varying lowp vec4 vv4_pickerColor;
varying lowp vec2 vv2_tex;
varying lowp float vf_dim;

void main() {
    vec2 lv2_pos = uv2_position + av4_pos.xy + mat2(av4_rot) * (av2_pos * av2_scale);
    gl_Position = vec4(lv2_pos, av4_pos.z, av4_pos.w) / uv4_scale;
    vv2_tex = av4_tex.xy + av4_tex.zw * av2_tex;
    vv4_pickerColor = av4_pickerColor;
    vf_dim = af_dim;
}
