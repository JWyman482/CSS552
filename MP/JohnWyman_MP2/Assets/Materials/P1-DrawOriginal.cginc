#pragma vertex VertexProgram
#pragma fragment FragmentProgram
            
#include "UnityCG.cginc"

struct DataFromVertex
{
    float4 vertex : POSITION;
};

struct DataForFragmentShader
{
    float4 vertex : SV_POSITION;
};

struct OutputFromFragmentShader
{
    float4 color : SV_Target;
};

float4 _Color;

DataForFragmentShader VertexProgram(DataFromVertex input)
{
    DataForFragmentShader output;
    float4 p = input.vertex;

    p = mul(unity_ObjectToWorld, p);
    p = mul(UNITY_MATRIX_V, p);
    output.vertex = mul(UNITY_MATRIX_P, p);

    return output;
}

OutputFromFragmentShader FragmentProgram(DataForFragmentShader input)
{
    OutputFromFragmentShader output;
    output.color = _Color;
    return output;
}
