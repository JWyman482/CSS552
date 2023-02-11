Shader "552_Shaders/552_M2_Shader"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
        _MyTex ("MyTex", 2D) = "white" {}
        _Ka("Ka", Color) = (0.1, 0.1, 0.1, 1)
        _Kd("Kd", Color) = (0.7, 0.8, 0.6, 1)
        //_Ks("Ks", Color) = (1.0, 1.0, 1.0, 1)
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
            #include "MyInclude/ControlFlags.cginc"

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
            //float3 _CameraPosition;
            //float3 _n;

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
            //float4 ComputeDiffuse(int lgtIndex, float3 n, float3 wpt) {
            //    float4 r = float4(0, 0, 0, 1);
            //    float3 L = LightPosition[lgtIndex];

            //    if (LightState[lgtIndex] != eLightOff) {  // light is on
            //        
            //        // Point Light
            //        L = normalize(LightPosition[lgtIndex].xyz - wpt);
            //        
            //        // Directional
            //        if (LightState[lgtIndex] != ePointLight)
            //            L = LightPosition.xyz;

            //        float nDotl = max(0.0, dot(n, L));
            //    }
            //    return r;
            //}

            //float4 ComputeSpecular(int lgtIndex, float3 n, float3 wpt, float3 cpt, float Shininess) {
            //    float4 r = float4(0, 0, 0, 1);
            //    float3 L = LightPosition[lgtIndex];
            //    float3 V = normalize((cpt - wpt)); // Camera view
            //    float3 R = reflect(L, n); // Reflection
            //    r = dot(V, R) ^ shininess;
            //    return r;
            //}

            float3 ComputeLightNormal(int lgtIndex, float3 wpt)
            {
                if (LightState[lgtIndex] == ePointLight) {
                    return normalize(LightPosition[lgtIndex].xyz - wpt);
                }

                if (LightState[lgtIndex] == eDirectionalLight) {
                    return LightPosition[lgtIndex];
                }
                
                return float3(0.0f, 0.0f, 0.0f);
            }

            
            float4 FragmentProgram(DataForFragmentShader input) : SV_Target
            {
                //float3 V = normalize(CameraPosition.xyz - input.worldPt);
                
                
                // Set Ambient Light
                float4 col = float4(0, 0, 0, 1);
                if (FlagIsOn(kAmbient)) col += _Ka;
                
                //// Set Diffused Light
                //if (FlagIsOn(kDiffuse)) {
                //    col *= _Kd;
                //    for (int lgt = 0; lgt < kNumLights; lgt++)
                //    {
                //        col += ComputeDiffuse(lgt, input.normal, input.worldPt);
                //        if (FlagIsOn(kSpecular)) {

                //        }
                //    }
                //}

                for (int lgt = 0; lgt < kNumLights; lgt++)
                {
                    float3 Lt = ComputeLightNormal(lgt, input.worldPt);
                    //float3 Rt = reflect(Lt, input.normal);

                    float4 Idt = float4(0, 0, 0, 0);
                    float4 Ist = float4(0, 0, 0, 0);

                    if (FlagIsOn(kDiffuse))
                    {
                        Idt = _Kd * max(0.0, dot(input.normal, Lt));
                    }

                    //if (FlagIsOn(kSpecular))
                    //{
                    //    Ist = _Ks * (max(0.0, dot(V, Rt))) ^ _n;
                    //}
                    col += (LightColor[lgt] * (Idt + Ist));
                }



                // Set Texture
                if (FlagIsOn(kTexture)) 
                    col *= tex2D(_MyTex, input.uv);

                return col;
            }
            ENDCG
        }
    }
}
