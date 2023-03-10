// Spot Light 2: Shadow caster

#pragma once

#include "MyInclude/MyShadowCaster.cginc"
#include "MyInclude/MyLights.cginc"
#include "MyInclude/MyMaterial.cginc"
#include "MyInclude/MyPhong.cginc"

#define THIS_LIGHT 2

v2f vert (appdata input)
{
    v2f o;
    float4 p = input.vertex;

    p = mul(unity_ObjectToWorld, p);  // objcet to world

    // projection computation must e performed in world space
    float3 d = normalize(LightPosition[THIS_LIGHT] - p);
    float nDotd = dot(_Normal, d);
    o.denom = nDotd;
    if (o.denom > NO_SHADOW)
        p = float4(ProjectToPlane(p, d, nDotd), 1);

    o.worldPt = p;
    p = mul(UNITY_MATRIX_V, p);  // To view space
    p = mul(UNITY_MATRIX_P, p);  // Projection 
    o.vertex = p;
    return o;
}

float4 frag (v2f i) : SV_Target
{
    if ((LightState[THIS_LIGHT] == eLightOff) || (i.denom < NO_SHADOW_IN_FRAG))
        discard;
    
    float3 L = normalize(LightPosition[THIS_LIGHT] - i.worldPt);
    float strength = AngularDropOff(THIS_LIGHT, L);

    if (strength <= 0.05)
        discard; // outside of the cone range

    // strength = 1 - strength;

    return  float4(_ShadowColor.rgb, strength*_ShadowColor.a);  // color of shadow  
}
