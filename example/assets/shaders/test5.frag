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
// https://www.shadertoy.com/view/ltVBRc

// ------ START SHADERTOY CODE -----
#define maxiter 250
#define m1 1.0
#define m2 0.9
#define r1 0.5
#define r2 0.5
#define v1 0.5
#define v2 0.95

void rotate (inout vec2 vertex, float rads)
{
    mat2 tmat = mat2(cos(rads), -sin(rads),
                     sin(rads), cos(rads));

    vertex.xy = vertex.xy * tmat;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = ( fragCoord - .5*iResolution.xy ) / iResolution.y;
    rotate(uv,0.35 * iTime);
    vec2 z = vec2(0.0, 0.0);
    float p = 0.0;
    float dist = 0.0;
    float x1 = tan(iTime*v1)*r1;
    float y1 = sin(iTime*v1)*r1;
    float x2 = tan(iTime*v2)*r2;
    float y2 = sin(iTime*v2)*r2;
    for (int i=0; i<maxiter; ++i)
    {
        z *= 2.0;
        z = mat2(z,-z.y,z.x) * z + uv;
        p = m1/sqrt((z.x-x1)*(z.x-x1)+(z.y-y1)*(z.y-y1))+m2/sqrt((z.x-x2)*(z.x-x2)+(z.y-y2)*(z.y-y2));
        dist = max(dist,p);

    }
    dist *= 0.0099;
    fragColor = vec4(dist/0.3, dist*dist/0.03, dist/0.112, 1.0);
}
// ------ END SHADERTOY CODE -----



void main() {
    iResolution = vec3(uResolution.x, uResolution.y, 0.);

    mainImage( fragColor, FlutterFragCoord().xy );
}


