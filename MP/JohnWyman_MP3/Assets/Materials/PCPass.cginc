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
    float4 VPoint = float4(_PCVPoint, 1);
    float w = _PCWeight;
    
    p = mul(unity_ObjectToWorld, p); // objcet to world
    p = mul(UNITY_MATRIX_V, p); // To eye space
    p = mul(UNITY_MATRIX_P, p); // Projection 

    if (FLAG_IS_ON(PC_ANIMATED))
        w = 0.5 * (1 + _SinTime.y);
    
    if (FLAG_IS_ON(PC_USE_OCVPOINT))
        VPoint = float4(_OCVPoint, 1);
    
    if (FLAG_IS_ON(PC_USE_WCVPOINT) && !FLAG_IS_ON(PC_USE_OCVPOINT))
        VPoint = float4(_WCVPoint, 1);
    
    VPoint = mul(UNITY_MATRIX_P, VPoint);
    
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