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

DataForFragmentShader VertexProgram(DataFromVertex input)
{
    DataForFragmentShader output;
    float4 p = input.vertex;
    float w = _WCWeight;
    float3 VPoint = _WCVPoint;
    
    if (FLAG_IS_ON(WC_ANIMATED))
        w = pow(abs(_SinTime.z), _WCRate);
    
    if (FLAG_IS_ON(WC_USE_OCVPOINT))
    {
        VPoint = _OCVPoint;
        p.xyz += w * (VPoint - p.xyz);
        p = mul(unity_ObjectToWorld, p);
    }
    else
    {
        p = mul(unity_ObjectToWorld, p);
        p.xyz += w * (VPoint - p.xyz);
    }
    
    p = mul(UNITY_MATRIX_V, p); // To eye space
    p = mul(UNITY_MATRIX_P, p); // Projection 
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