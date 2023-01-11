#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

struct DataForFragmentShader
{
    float4 vertex : POSITION;
};

struct v2f
{
    float4 vertex : SV_POSITION;
};

struct OutputFromFragmentShader
{
    float4 color : SV_Target;
};

float4 _Color;

v2f vert(DataForFragmentShader v)
{
    v2f o;
    
    float4 p = v.vertex;
    p = mul(unity_ObjectToWorld, p);
    p = mul(UNITY_MATRIX_V, p);
    p = mul(UNITY_MATRIX_P, p);
    
    o.vertex = p;
    return o;
}

OutputFromFragmentShader frag(v2f i)
{
    OutputFromFragmentShader o;
    o.color = _Color;
    return o;
}