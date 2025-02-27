#ifndef DIR_PASS
#define DIR_PASS

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
};

#define LIGHT 1
    //#define _LightPos LightPosition[LIGHT]

float3 _Normal; // normal of plane
float _D; // D of plane
float4 _ShadowColor; // color of the shadow
float3 _LightPos;

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

    p = mul(UNITY_MATRIX_V, p);
    p = mul(UNITY_MATRIX_P, p);
    o.vertex = p;
    return o;
}

float4 frag(v2f i) : SV_Target
{
    if (LightState[LIGHT] == eLightOff)
        discard;
    
    return _ShadowColor; // color of shadow
}

#endif //  DIR_PASS