#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

struct DataFromVertex 
{
    float4 vertex : POSITION; 
};

struct DataForFragmentShader 
{
    float4 vertex : SV_POSITION; 
};

DataForFragmentShader vert(DataFromVertex v) 
{
    DataForFragmentShader o;
    float4 p = v.vertex;

    p = mul(unity_ObjectToWorld, p);
    p = mul(UNITY_MATRIX_V, p); 
    p = mul(UNITY_MATRIX_P, p);
    o.vertex = p;
    return o;
}

float4 frag(DataForFragmentShader i) : SV_Target
{
    return float4(1, 1, 1, 1);
}