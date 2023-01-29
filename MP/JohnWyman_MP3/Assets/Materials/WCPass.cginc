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

float4 transVert(float4 p, float4 VPoint, float w)
{
    p.xyz += w * (VPoint - p);
    return p;
}

DataForFragmentShader VertexProgram(DataFromVertex input)
{
    DataForFragmentShader output;
    float4 p = input.vertex;
    float w;
    float4 VPoint = float4(_WCVPoint, 1);

    p = mul(unity_ObjectToWorld, p);
    
    if (FLAG_IS_ON(WC_ANIMATED))
        w = pow(abs(_SinTime.z), _WCRate);
    else
        w = _WCWeight;
    
    if (FLAG_IS_ON(WC_USE_OCVPOINT))
    {
        VPoint = float4(_OCVPoint, 1);
        VPoint = mul(unity_ObjectToWorld, VPoint);
    }
    
    p.xyz += w * (VPoint - p);
    
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