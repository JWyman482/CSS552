#pragma once

#pragma vertex vert
#pragma fragment frag

struct appdata { float4 vertex : POSITION; };
struct v2f { float4 vertex : SV_POSITION; 
             float3 worldPt : TEXCOORD0;
             float denom : TEXCOORD1;  // not a semantic, will not be interpolated?
            };

float3 _Normal; // normal of plane
float _D; // D of plane
float4 _ShadowColor; // color of the shadow

#define NO_SHADOW         0.0001
#define NO_SHADOW_IN_FRAG (10*NO_SHADOW)

// p: Vertex position
// fromLight: light diretion (from light)
// nDotd: dot(_Normal, fromLight)
// return: project onto the plane: dot(_Normal, aPos) - _D = 0
float3 ProjectToPlane(float3 p, float3 fromLight, float nDotd) {
    float numerator = _D - dot(_Normal, p);
    float t = 0.99 * numerator / nDotd;
    return p + t * fromLight;
}