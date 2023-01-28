#pragma vertex VertexProgram
#pragma fragment FragmentProgram

#include "UnityCG.cginc"
#include "Structs.cginc"

int _UserControl;
float3 _OCVPoint;
float _OCWeight;

float4 transVert(float4 p, float3 VPoint, float w)
{
    p.xyz += w * (VPoint.xyz - p.xyz);
    return p;
}

DataForFragmentShader VertexProgram(DataFromVertex input)
{
    DataForFragmentShader output;
    float4 p = input.vertex;
    float w;

    if (FLAG_IS_ON(OC_ANIMATED))   
        w = 0.5 * (1 + _SinTime.z);
    else
        w = _OCWeight;

    
    if (FLAG_IS_ON(OC_USE_VPOINT)) 
        p = transVert(p, _OCVPoint, w);         // Move vertices to OCVPoint in OC
    else
        p = transVert(p, float3(0, 0, 0), w);   // Move vertices to (0, 0, 0) in OC

    
    p = mul(unity_ObjectToWorld, p);            // Transform: To world
    p = mul(UNITY_MATRIX_V, p);                 // Transform: To eye space
    p = mul(UNITY_MATRIX_P, p);                 // Transform: To perspective
    output.vertex = p;
    return output;
}

OutputFromFragmentShader FragmentProgram(DataForFragmentShader input)
{
    OutputFromFragmentShader output;
    if (!FLAG_IS_ON(OC_SHOW))
        discard;
    output.color = float4(1, 0, 0, 1);
    return output;
}