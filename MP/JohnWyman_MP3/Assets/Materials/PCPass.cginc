#pragma vertex VertexProgram
#pragma fragment FragmentProgram

#include "UnityCG.cginc"
#include "Structs.cginc"   

int _UserControl;
float3 _WCVPoint;
float3 _OCVPoint;
float3 _PCVPoint;
float _PCWeight;

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
    
    if (FLAG_IS_ON(PC_ANIMATED))
        w = 0.5 * (1 + _SinTime.y);
    else
        w = _PCWeight;
    
    if (FLAG_IS_ON(PC_USE_OCVPOINT))
    {
        p = transVert(p, _OCVPoint, w);     // Move the vertices
        p = mul(unity_ObjectToWorld, p);    // Transform: To world
        p = mul(UNITY_MATRIX_V, p);         // Transform: To eye space
        p = mul(UNITY_MATRIX_P, p);         // Transform: To perspective

    }

    // OC flag takes precedent
    if (FLAG_IS_ON(PC_USE_WCVPOINT) && !FLAG_IS_ON(PC_USE_OCVPOINT))
    {
        p = mul(unity_ObjectToWorld, p);    // Transform: To world
        p = transVert(p, _WCVPoint, w);     // Move the vertices
        p = mul(UNITY_MATRIX_V, p);         // Transform: To eye space
        p = mul(UNITY_MATRIX_P, p);         // Transform: To perspective
    }

    if (!FLAG_IS_ON(PC_USE_WCVPOINT) && !FLAG_IS_ON(PC_USE_OCVPOINT))
    {
        p = mul(unity_ObjectToWorld, p);    // Transform: To world
        p = mul(UNITY_MATRIX_V, p);         // Transform: To eye space
        p = mul(UNITY_MATRIX_P, p);         // Transform: To perspective

        p.xyz /= p.w;
        p = transVert(p, _PCVPoint, w);     // Move the vertices
        p.xyz *= p.w;
    }
        
    output.vertex = p;
    return output;
}

OutputFromFragmentShader FragmentProgram(DataForFragmentShader input)
{
    OutputFromFragmentShader output;
    if (!FLAG_IS_ON(PC_SHOW))
        discard;
    output.color = float4(0.5, 0.2, 0.2, 1);
    return output;
}