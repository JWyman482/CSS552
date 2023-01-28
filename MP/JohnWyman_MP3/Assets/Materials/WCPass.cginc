#pragma vertex VertexProgram
#pragma fragment FragmentProgram

#include "UnityCG.cginc"
#include "Structs.cginc"   

int _UserControl;
float4 _Color;
float3 _WCVPoint;
float3 _OCVPoint;
float _WCWeight;
float _WCRate;
int _Test;

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
    
    if (FLAG_IS_ON(WC_ANIMATED))
        w = pow(abs(_SinTime.z), _WCRate);
    else
        w = _WCWeight;
    
    if (FLAG_IS_ON(WC_USE_OCVPOINT))
    {
        p = transVert(p, _OCVPoint, w);     // Move vertices - in OC
        p = mul(unity_ObjectToWorld, p);    // Transform: To world
    }
    else
    {
        p = mul(unity_ObjectToWorld, p);    // Transform: To world
        p = transVert(p, _WCVPoint, w);     // Move vertices - in WC
    }
    
    p = mul(UNITY_MATRIX_V, p);             // Transform: To eye space
    p = mul(UNITY_MATRIX_P, p);             // Transform: To perspective
    output.vertex = p;
    return output;
}

OutputFromFragmentShader FragmentProgram(DataForFragmentShader input)
{
    OutputFromFragmentShader output;
    if (!FLAG_IS_ON(WC_SHOW))
        discard;
    output.color = float4(0, 0, 1, 1);
    return output;
}