#pragma vertex VertexProgram
#pragma fragment FragmentProgram

#include "UnityCG.cginc"
#include "Structs.cginc"   

int _UserControl;
float4 _Color;

DataForFragmentShader VertexProgram(DataFromVertex input)
{
    DataForFragmentShader output;
    float4 p = input.vertex;

    p = mul(unity_ObjectToWorld, p); // objcet to world
    p = mul(UNITY_MATRIX_V, p); // To eye space
    p = mul(UNITY_MATRIX_P, p); // Projection 
                    
    output.vertex = p;

    return output;
}

OutputFromFragmentShader FragmentProgram(DataForFragmentShader input)
{
    OutputFromFragmentShader output;
    if (!FLAG_IS_ON(SHOW_ORIGINAL))
        discard;
    output.color = _Color;
    return output;
}
