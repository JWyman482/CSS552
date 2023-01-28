#pragma vertex VertexProgram
#pragma fragment FragmentProgram

#include "UnityCG.cginc"
#include "Structs.cginc"

int _UserControl;
float3 _OCVPoint;
float _OCWeight;

DataForFragmentShader VertexProgram(DataFromVertex input)
{

    DataForFragmentShader output;
    float4 p = input.vertex;
    float3 VPoint = (0, 0, 0);
    float w = _OCWeight;

    if (FLAG_IS_ON(OC_ANIMATED))   
        w = 0.5 * (1 + _SinTime.z);
                    
    if (FLAG_IS_ON(OC_USE_VPOINT)) 
        VPoint = _OCVPoint;
    
    p.xyz += w * (VPoint - p.xyz);

    p = mul(unity_ObjectToWorld, p); // objcet to world
    p = mul(UNITY_MATRIX_V, p); // To eye space
    p = mul(UNITY_MATRIX_P, p); // Projection 

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