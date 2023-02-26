#pragma once

// located at: C:\Program Files\Unity\Hub\Editor\2021.3.10f1\Editor\Data\CGIncludes
#include "UnityCG.cginc"
#include "MyMaterial.cginc"
#include "MyLights.cginc"
#include "MyPhong.cginc"

struct DataFromVertex
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct DataForFragmentShader
{
    float4 vertex : SV_POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
};

sampler2D _MainTex;
float4 _CameraPosition;
