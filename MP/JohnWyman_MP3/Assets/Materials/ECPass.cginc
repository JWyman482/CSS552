#pragma vertex VertexProgram
#pragma fragment FragmentProgram

#include "UnityCG.cginc"
#include "Structs.cginc"   

int _UserControl;
float3 _WCVPoint;
float3 _OCVPoint;
float _ECWeight;
float _ECNear;


DataForFragmentShader VertexProgram(DataFromVertex input)
{
    DataForFragmentShader output;
    float4 p = input.vertex;
    float w = _ECWeight;
    float4 VPoint = float4(0, 0, -_ECNear, 1);

    p = mul(unity_ObjectToWorld, p);                // Transform vertex to world
    p = mul(UNITY_MATRIX_V, p);                     // Transform vertex to eye space
    
    if (FLAG_IS_ON(EC_ANIMATED))
        w = 0.5 * (1 + _CosTime.z);
    
    if (FLAG_IS_ON(EC_USE_OCVPOINT))
    {
        VPoint = float4(_OCVPoint, 1);              // Set vanishing point to OCVPoint
        VPoint = mul(unity_ObjectToWorld, VPoint);  // Transform vanishing point from object to world
        VPoint = mul(UNITY_MATRIX_V, VPoint);       // Transform vanishing point from world to eye space
    }
    
    if (FLAG_IS_ON(EC_USE_WCVPOINT) && !FLAG_IS_ON(EC_USE_OCVPOINT))
    {
        VPoint = float4(_WCVPoint, 1);              // Set vanishing point to WCVPoint
        VPoint = mul(UNITY_MATRIX_V, VPoint);       // Transform vanishing point from world to eye space
    }
    
    if (FLAG_IS_ON(EC_ONLY_Z))
        p.z += w * (VPoint.z - p.z);
    else
        p.xyz += w * (VPoint - p);
    
    p = mul(UNITY_MATRIX_P, p);                     // Transform vertex to perspective
    output.vertex = p;
    return output;
}

OutputFromFragmentShader FragmentProgram(DataForFragmentShader input)
{
    OutputFromFragmentShader output;
    if (!FLAG_IS_ON(EC_SHOW))
        discard;
    output.color = float4(0.5, 1, 1, 1);
    return output;
}