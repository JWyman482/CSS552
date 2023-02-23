#ifndef SPT_PASS
#define SPT_PASS

#pragma vertex vert
#pragma fragment frag
            
#include "UnityCG.cginc"
#include "MyLights.cginc"

struct appdata
{
    float4 vertex : POSITION;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float3 wpt : TEXCOORD0;
};

#define LIGHT 2
    //#define _LightPos LightPosition[LIGHT]

float3 _Normal; // normal of plane
float _D; // D of plane
float4 _ShadowColor; // color of the shadow
float3 _LightPos;
float _ShadowWeight;

v2f vert(appdata input)
{
    v2f o;
    float4 p = input.vertex;
    float3 Vl;
    //_LightPos = LightPosition[0];

    p = mul(unity_ObjectToWorld, p);

    // Set light position based on type
    if (LIGHT == 1)
    {
        _LightPos = p;
        Vl = LightDirection[LIGHT];
    }
    else
    {
        _LightPos = LightPosition[LIGHT];
        Vl = (p.xyz - _LightPos);
    }
    
    float t = 0.99 * (_D - (dot(_Normal, _LightPos))) / (dot(_Normal, Vl));
                // fudge a little to not lie right on top of the receiver
                // IF light is on the plane, Vl will be zero!! The shader will crash!

    p = float4(_LightPos + t * Vl, 1);
    o.wpt = p;
    
    p = mul(UNITY_MATRIX_V, p);
    p = mul(UNITY_MATRIX_P, p);
    o.vertex = p;
    return o;
}

float4 frag(v2f i) : SV_Target
{
    if (LightState[LIGHT] == eLightOff)
        discard;
    //_ShadowColor *= ShadowAngularDropoff(2, LightPosition[2]);
    float3 L = normalize(LightPosition[LIGHT] - i.wpt);
    float strength = 0.0;
    float cosL = dot(LightDirection[LIGHT], L);
    float num = cosL - SpotOuterCos[LIGHT];
    if (num > 0.0)
    {
        if (cosL > SpotInnerCos[LIGHT]) 
            strength = 1.0;
        else
        {
            float denom = SpotInnerCos[LIGHT] - SpotOuterCos[LIGHT];
            strength = smoothstep(0.0, 1.0, pow(num / denom, SpotDropOff[LIGHT]));
        }
    }
    //return strength;
    _ShadowColor.a = strength;
    //return _ShadowColor * _ShadowWeight; // color of shadow
    return _ShadowColor;
}

#endif //  SPT_PASS