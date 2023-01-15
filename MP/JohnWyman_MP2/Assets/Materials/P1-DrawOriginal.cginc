#pragma once
#pragma vertex VertexProgram
#pragma fragment FragmentProgram
            
#include "UnityCG.cginc"

struct DataFromVertex
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct DataForFragmentShader
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
};

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _Color;
float _ColorWeight;

DataForFragmentShader VertexProgram(DataFromVertex input)
{
    DataForFragmentShader output;
    float4 p = input.vertex;

    p = mul(unity_ObjectToWorld, p);
    p = mul(UNITY_MATRIX_V, p);
    p = mul(UNITY_MATRIX_P, p);
    output.vertex = p; 
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    
    return output;
}

float4 FragmentProgram(DataForFragmentShader input) : SV_Target
{
    
    float4 c1 = tex2D(_MainTex, input.uv);
    
    
    return _ColorWeight * c1 + (1 - _ColorWeight) * _Color;
}
