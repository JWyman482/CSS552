#pragma vertex VertexProgram
#pragma fragment FragmentProgram

#include "UnityCG.cginc"
#include "Structs.cginc"   

int _UserControl;
float3 _WCVPoint;
float3 _OCVPoint;
float _ECWeight;
float _ECNear;

float4 transVert(float4 p, float3 VPoint, float w) {
    if (FLAG_IS_ON(EC_ONLY_Z))
        p.z += w * (VPoint.z - p.z);
    else
        p.xyz += w * (VPoint.xyz - p.xyz);
    return p;
}

DataForFragmentShader VertexProgram(DataFromVertex input)
{
    DataForFragmentShader output;
    float4 p = input.vertex;
    float w;
    
    if (FLAG_IS_ON(EC_ANIMATED))
        w = 0.5 * (1 + _CosTime.z);
    else
        w = _ECWeight;
    
    if (FLAG_IS_ON(EC_USE_OCVPOINT))
    {
        p = transVert(p, _OCVPoint, w);             // Move vertices to OCVPoint in OC
        p = mul(unity_ObjectToWorld, p);            // Transform: To world
        p = mul(UNITY_MATRIX_V, p);                 // Transform: To eye space
    }

    // OC flag takes precedent
    if (FLAG_IS_ON(EC_USE_WCVPOINT) && !FLAG_IS_ON(EC_USE_OCVPOINT))
    {
        p = mul(unity_ObjectToWorld, p);            // Transform: To world
        p = transVert(p, _WCVPoint, w);             // Move vertices to WCVPoint in WC
        p = mul(UNITY_MATRIX_V, p);                 // Transform: To eye space
    }

    if (!FLAG_IS_ON(EC_USE_WCVPOINT) && !FLAG_IS_ON(EC_USE_OCVPOINT))
    {
        p = mul(unity_ObjectToWorld, p);            // Transform: To world
        p = mul(UNITY_MATRIX_V, p);                 // Transform: To eye space
        p = transVert(p, float3(0, 0, -_ECNear), w);// Move vertices to center of camera in EC
    }
   
    p = mul(UNITY_MATRIX_P, p);                     // Transform: To perspective
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