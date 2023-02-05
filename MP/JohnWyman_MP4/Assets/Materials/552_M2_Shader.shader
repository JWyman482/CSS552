Shader "552_Shaders/552_M2_Shader"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
        _MyTex ("MyTex", 2D) = "white" {}
        _Ka("Ka", Color) = (0.5, 0.5, 0.5, 1)
        _Kd("Kd", Color) = (1.0, 1.0, 1.0, 1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            // located at: C:\Program Files\Unity\Hub\Editor\2021.3.10f1\Editor\Data\CGIncludes
            #include "UnityCG.cginc"
            #include "MyInclude/MyPhong.cginc"
            #include "MyInclude/MyLights.cginc"

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
                float3 worldPt: TEXCOORD1;
            };

            sampler2D _MyTex;
            float4 _MyTex_ST;
            float4 _Kd;
            float4 _Ka;

            DataForFragmentShader VertexProgram(DataFromVertex input)
            {
                DataForFragmentShader output;
                float4 p = input.vertex;
                p = mul(unity_ObjectToWorld, p);  // object to world
                output.worldPt = p.xyz;
                p = mul(UNITY_MATRIX_V, p);  // To view space
                p = mul(UNITY_MATRIX_P, p);  // Projection 
                
                output.uv = TRANSFORM_TEX(input.uv, _MyTex);  // for texture placement
                output.vertex = p;

                output.normal = normalize(mul(input.normal, (float3x3)unity_WorldToObject));
                return output;
            }

            // lgtIndex: index into the light arrays
            // n: normal at visible point (in WC)
            // wpt: pt to be shaded (in WC)
            float4 ComputeDiffuse(int lgtIndex, float3 n, float3 wpt) {
                float4 r = float4(0, 0, 0, 1);
                if (LightState[lgtIndex] != eLightOff) {  // light is on
                    float3 L = normalize(LightPosition[lgtIndex].xyz - wpt);
                    float nDotl = max(0.0, dot(n, L));
                    r = LightColor[lgtIndex] * nDotl;
                }
                return r;
            }

            
            float4 FragmentProgram(DataForFragmentShader input) : SV_Target
            {
                // Set Ambient Light
                float4 col = float4(0.5, 0.5, 0.5, 1);
                if (FlagIsOn(kAmbient)) col = _Ka;
                
                // Set Diffused Light
                if (FlagIsOn(kDiffuse)) {
                    col *= _Kd;
                    for (int lgt = 0; lgt < kNumLights; lgt++)
                    {
                        col += ComputeDiffuse(lgt, input.normal, input.worldPt);
                    }
                }

                // Set Texture
                if (FlagIsOn(kTexture)) col *= tex2D(_MyTex, input.uv);

                return col;
            }
            ENDCG
        }
    }
}
