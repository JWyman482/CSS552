Shader "552_Shaders/552_M2_Shader"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
        _Tex("Texture", 2D) = "white" {}
        _Kd("Kd", Color) = (1, 1, 1, 1)
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
                float3 worldPt : TEXCOORD1;
            };

            #define MAX_LIGHTS 4
            #define LIGHT_OFF 0
            #define LIGHT_ON 1
            
            sampler2D _Tex;
            float4 _Tex_ST;
            float4 _Kd;

            float4 _LightPosition[MAX_LIGHTS];
            float4 _LightColor[MAX_LIGHTS];
            float _LightFlag[MAX_LIGHTS];

            int _Flag;
            #define FLAG_IS_SET(f) (_Flag & f)
            #define FLAG_NONE       0x00
            #define FLAG_SHOW_TEX   0x01

            DataForFragmentShader VertexProgram(DataFromVertex input)
            {
                DataForFragmentShader output;
                float4 p = input.vertex;
                p = mul(unity_ObjectToWorld, p);  // object to world
                output.worldPt = p.xyz;
                p = mul(UNITY_MATRIX_V, p);  // To view space
                p = mul(UNITY_MATRIX_P, p);  // Projection 

                output.uv = TRANSFORM_TEX(input.uv, _Tex);
                output.vertex = p;
                output.normal = normalize(mul(input.normal, (float3x3)unity_WorldToObject));
                return output;
            }

            // lgtIndex: index into the light arrays
            // n: normal at visible point (in WC)
            // wpt: pt to be shaded (in WC)
            float4 ComputeDiffuse(int lgtIndex, float3 n, float3 wpt) {
                float4 r = float4(0, 0, 0, 1);
                if (_LightFlag[lgtIndex] == LIGHT_ON) {  // light is on
                    float3 L = normalize(_LightPosition[lgtIndex].xyz - wpt);
                    float nDotl = max(0.0, dot(n, L));
                    r = _LightColor[lgtIndex] * nDotl;
                }
                return r;
            }

            float4 FragmentProgram(DataForFragmentShader input) : SV_Target
            {
                float4 col = float4(0, 0, 0, 1);
                for (int lgt = 0; lgt < MAX_LIGHTS; lgt++) {
                    col += ComputeDiffuse(lgt, input.normal, input.worldPt);
                }

                col *= _Kd;

                if (FLAG_IS_SET(FLAG_SHOW_TEX))
                    col *= tex2D(_Tex, input.uv);

                return col;
            }
            ENDCG
        }
    }
}
