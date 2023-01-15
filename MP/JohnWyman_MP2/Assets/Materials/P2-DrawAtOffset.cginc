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
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
};


int _XType;
int _ZType;
float _XPeriod;
float _ZPeriod;
float _XAmplitude;
float _ZAmplitude;
float _Offset;
float _XZBlend;
int _XAnimate;
int _ZAnimate;
sampler2D _MainTex;
float4 _MainTex_ST;
float4 _Color;
float _ColorWeight;
//int _BitFlag;

#define XSINE     0x01
#define ZSINE     0x02
#define DBLPASS   0x08
#define XANIM     0x10
#define ZANIM     0x20

DataForFragmentShader VertexProgram(DataFromVertex input)
{
    DataForFragmentShader output;
    float4 p = input.vertex;
    //int XType;
    //int XAnimate;
    //int ZType;
    //int ZAnimate;
    
    //if (_BitFlag & XSINE)
    //{
    //    _XType = 1;
    //}
    //else
    //{
    //    _XType = 0;
    //}

    //if (_BitFlag & ZSINE)
    //{
    //    ZType = 1;
    //}
    //else
    //{
    //    ZType = 0;
    //}
    
    //if (_BitFlag & XANIM)
    //{
    //    XAnimate = 1;
    //}
    //else
    //{
    //    XAnimate = 0;
    //}
    
    //if (_BitFlag & ZANIM)
    //{
    //    ZAnimate = 1;
    //}
    //else
    //{
    //    ZAnimate = 0;
    //}
    
    if (_XType == 1)
    {
        p.y = _XZBlend * (_XAmplitude * sin(_XPeriod * (p.x - (_Time.x * _XAnimate)) * UNITY_TWO_PI / 2));
    }
    else if (_XType == 0)
    {
        p.y = _XZBlend * (_XAmplitude * cos(_XPeriod * (p.x - (_Time.x * _XAnimate)) * UNITY_TWO_PI / 2));
    }
    
    if (_ZType == 1)
    {
        p.y += (1 - _XZBlend) * (_ZAmplitude * sin(_ZPeriod * (p.z - (_Time.x * _ZAnimate)) * UNITY_TWO_PI / 2));
    }
    else if (_ZType == 0)
    {
        p.y += (1 - _XZBlend) * (_ZAmplitude * cos(_ZPeriod * (p.z - (_Time.x * _ZAnimate)) * UNITY_TWO_PI / 2));

    }
    
    p.y += _Offset;
    
    p = mul(unity_ObjectToWorld, p);
    p = mul(UNITY_MATRIX_V, p);
    p = mul(UNITY_MATRIX_P, p);
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    
    output.vertex = p;
    return output;
}

float4 FragmentProgram(DataForFragmentShader input) : SV_Target
{
    
    float4 c1 = tex2D(_MainTex, input.uv);
    
    
    return _ColorWeight * c1 + (1 - _ColorWeight) * _Color;
}
