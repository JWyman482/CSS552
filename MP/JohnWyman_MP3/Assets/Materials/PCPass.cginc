#pragma vertex VertexProgram
#pragma fragment FragmentProgram

#include "UnityCG.cginc"
#include "Structs.cginc"   

int _UserControl;
float3 _WCVPoint;
float3 _OCVPoint;
float3 _PCVPoint;
float _PCWeight;

DataForFragmentShader VertexProgram(DataFromVertex input)
{
    DataForFragmentShader output;
    float4 p = input.vertex;
    float w = _PCWeight;
    float4 VPoint = float4(_PCVPoint, 1);
    
    p = mul(unity_ObjectToWorld, p);                // Transform vertex to world
    p = mul(UNITY_MATRIX_V, p);                     // Transform vertex to eye space
    p = mul(UNITY_MATRIX_P, p);                     // Transform vertex to perspective
    
    if (FLAG_IS_ON(PC_ANIMATED))
        w = 0.5 * (1 + _SinTime.y);
    
    if (FLAG_IS_ON(PC_USE_OCVPOINT))
    {
        VPoint = float4(_OCVPoint, 1);              // Set vanishing point to OCVPoint
        VPoint = mul(unity_ObjectToWorld, VPoint);  // Transform vanishing point from object to world
        VPoint = mul(UNITY_MATRIX_V, VPoint);       // Transform vanishing point from world to eye space
        VPoint = mul(UNITY_MATRIX_P, VPoint);       // Transform vanishing point from eye to perspective
    }

    // OC flag takes precedent
    if (FLAG_IS_ON(PC_USE_WCVPOINT) && !FLAG_IS_ON(PC_USE_OCVPOINT))
    {
        VPoint = float4(_WCVPoint, 1);              // Set vanishing point to WCVPoint
        VPoint = mul(UNITY_MATRIX_V, VPoint);       // Transform vanishing point from world to eye space
        VPoint = mul(UNITY_MATRIX_P, VPoint);       // Transform vanishing point from eye to perspective        
    }
    
    VPoint /= VPoint.w;
    p.xyz /= p.w;
    p.xyz += w * (VPoint - p);
    p.xyz *= p.w;
    
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