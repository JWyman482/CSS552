#pragma vertex vert

#include "UnityCG.cginc"

struct DataFromVertex // Input
{
    float4 vertex : POSITION; // {x, y, z, w}. Mandatory.
};

struct DataForFragmentShader // Vertex processor to Fragment processor - output
{
    float4 vertex : SV_POSITION; // Id's which pixel will be rendered
    float4 color : COLOR;
};

float4 _Color;

DataForFragmentShader vert(DataFromVertex v) // Applies to Vertex Processor
{
    DataForFragmentShader o;
    float4 p = v.vertex;
    p = mul(unity_ObjectToWorld, p); //Object to World - In game transform
    p = mul(UNITY_MATRIX_V, p); // To View Space - Camera location
    p = mul(UNITY_MATRIX_P, p); // To Projection - Universal scale for displays
    
    
    o.vertex = p;
    o.color = _Color;
    return o;
}