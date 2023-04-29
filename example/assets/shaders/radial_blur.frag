#version 460 core
#include <flutter/runtime_effect.glsl>
precision mediump float;

layout(location = 0) uniform sampler2D iChannel0;
layout(location = 1) uniform sampler2D iChannel1;
layout(location = 2) uniform sampler2D iChannel2;
layout(location = 3) uniform sampler2D iChannel3;
layout(location = 4) uniform vec2 uResolution;
layout(location = 5) uniform float iTime;
layout(location = 6) uniform vec4 iMouse;

out vec4 fragColor;

vec3 iResolution;

// credits:
// https://www.shadertoy.com/view/tt2BWd

// ------ START SHADERTOY CODE -----
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    vec2 origin = vec2(sin(iTime), cos(iTime));

    vec2 diff = uv - origin;

    vec4 col = vec4(0.);

    const int steps = 128;
    float distanceFactor = sin(iTime)/5.;

    float fSteps = float(steps);
    float stepSize = 1. / fSteps;

    for (int i = 0; i < steps; i++) {
        float fac = float(i) * stepSize;
        vec2 pos = uv - diff * (fac * distanceFactor);
        //col += texture(iChannel0, pos) * stepSize;
        col += texture(iChannel0, pos) * (float(steps - i) / fSteps) * stepSize;
    }

    col *= 2.;


    // Output to screen
    fragColor = vec4(col.rgb,1.0);
}
// ------ END SHADERTOY CODE -----



void main() {
    iResolution = vec3(uResolution.x, uResolution.y, 0.);

    mainImage( fragColor, FlutterFragCoord().xy );
}