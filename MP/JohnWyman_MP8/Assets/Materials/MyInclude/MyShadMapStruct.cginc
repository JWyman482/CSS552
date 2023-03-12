#pragma once

// located at: C:\Program Files\Unity\Hub\Editor\2021.3.10f1\Editor\Data\CGIncludes
#include "UnityCG.cginc"
#include "MyMaterial.cginc"
#include "MyLights.cginc"
#include "MyPhong.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
    float3 lightNDC : TEXCOORD2;
    float3 normal : NORMAL;
    float4 vertex : SV_POSITION;
};


