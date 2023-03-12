Shader "552_Shaders/ShadMap_Phong"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "DepthValue"="InWC"}
        LOD 100

        Pass // normal phong pass
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Includes UnityCG, MyMaterial, MyLights, MyPhong
            #include "UnityCG.cginc"
            #include "./MyInclude/MyMaterial.cginc"
            #include "./MyInclude/MyLights.cginc"
            #include "./MyInclude/MyPhong.cginc"

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

            sampler2D _MainTex;
            float4 _CameraPosition;
            float4 _LightPos;

            sampler2D _ShadowMap;
            float4 _ShadowColor;
            float _DepthBias;
            float _NormalBias;
            float4x4 _WorldToLightNDC;
            

            // For debugging
            uint _MapFlag;
            float _DebugDistScale;  // to scale down distance for drawing
            static const int kShowMapDistance = 0x01;
            static const int kShowMapDistanceWithBias = 0x02;
            static const int kShowLightDistance = 0x04;
            static const int kShowShadowInRed = 0x08;
            static const int kShowMapWC = 0x20;
            static const int kFilter3 = 0x40;
            static const int kFilter5 = 0x80;
            static const int kFilter9 = 0x100;
            static const int kFilter15 = 0x200;
            
            float _kInvWidth; // Default
            float _kInvHeight;// Default

            #define V_TO_F4(V) float4(V,V,V,1)

            #define DEBUG_SHOW(FLAG, VALUE, SCALE) {        \
                if (_MapFlag & FLAG) {                      \
                    return (VALUE * SCALE);                 \
                }                                           \
            }            

            /* Helper Functions */
            bool InShadow(float distToLight, float2 uv) {
                return (distToLight > (tex2D(_ShadowMap, uv).a + _DepthBias));
            }

            #include "./MyInclude/ShadowKernel.cginc"
            INSHADOW_SIZE(3)
            INSHADOW_SIZE(5)
            INSHADOW_SIZE(9)
            INSHADOW_SIZE(15)

            float LightStrength(float d, float2 uv) {
                float blocked = 0;
                if (_MapFlag & kFilter3) blocked = InShadow_3(d, uv);
                else if (_MapFlag & kFilter5) blocked = InShadow_5(d, uv);
                else if (_MapFlag & kFilter9) blocked = InShadow_9(d, uv);
                else if (_MapFlag & kFilter15) blocked = InShadow_15(d, uv);
                else blocked = InShadow(d, uv) ? 1 : 0;
                return 1-blocked;
            }

            v2f vert (appdata v)
            {
                v2f output;
                float4 p; 
                p = mul(unity_ObjectToWorld, v.vertex); // To Object Space
                p.xyz = p.xyz + _NormalBias * v.normal; // SMap: Normal Bias
                output.worldPos = p.xyz;

                p = mul(UNITY_MATRIX_V, p); // To Camera Space
                p = mul(UNITY_MATRIX_P, p); // To NDC
                output.vertex = p;
                // Normalize for diffuse light calculation
                output.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                output.uv = v.uv;

                // Compute/convert vertex position (WC) to light's NDC space
                // This tells us where the vertex is according to the light's NDC perspective
                // output.vertex tells us where the vertex is according to the main camera's NDC. 
                float4 lNDC = mul(_WorldToLightNDC, float4(output.worldPos, 1));
                output.lightNDC = lNDC.xyz / lNDC.w;
                output.lightNDC = (output.lightNDC + 1) * 0.5;
                return output;
            }

            float4 frag (v2f input) : SV_Target
            {
                float4 textureColor = float4(0.9, 0.7, 0.7, 1.0);

                // Shadow - light distance
                float3 L = LightPosition[0] - input.worldPos;
                // float3 L = _LightPos;
                float distToLight = length(L);
                DEBUG_SHOW(kShowLightDistance, V_TO_F4(distToLight), _DebugDistScale)


                float4 wcPt = tex2D(_ShadowMap, input.lightNDC);
                float distFromMap = wcPt.a;
                DEBUG_SHOW(kShowMapDistance, V_TO_F4(distFromMap), _DebugDistScale)
                distFromMap += _DepthBias;
                DEBUG_SHOW(kShowMapDistanceWithBias, V_TO_F4(distFromMap), _DebugDistScale)
                
                if (distToLight > distFromMap) {
                    DEBUG_SHOW(kShowShadowInRed, float4(1, 0, 0, 1), 1)
                }

                // If texture is flagged, grab the texture pixel
                if (FlagIsOn(kTexture))
                    textureColor = tex2D(_MainTex, input.uv);

                float4 shadedResult = float4(0.1, 0.1, 0.1, 1);
                
                // If Ambient is flagged, grab/set the Ka
                if (FlagIsOn(kAmbient))
                    shadedResult = float4(_Ka.xyz, 1);
                
                for (int i = 0; i < kNumLights; i++) 
                {
                    if (LightState[i] != eLightOff) {
                        float lgtStrength = LightStrength(distToLight, input.lightNDC);
                        float4 phongResult = PhongIlluminate(_CameraPosition, input.worldPos, i, input.normal, textureColor * lgtStrength);
                        float4 phongShadowBlend = (phongResult * (lgtStrength)) + ((1 - lgtStrength) * _ShadowColor);
                        // float4 phongShadowBlend = phongResult;
                        shadedResult += phongShadowBlend;
                    }
                }

                return shadedResult;
            }
            // float4 frag (v2f i) : SV_Target
            // {
            //     // sample the texture
            //     float4 col = float4(0.9, 0.7, 0.7, 1.0);
            //     if ((i.uv.x != 0) && (i.uv.y != 0))
            //         col = tex2D(_MainTex, i.uv);
                
            //     float3 L = _LightPos - i.worldPos;
            //     float distToLight = length(L);
            //     L = L / distToLight;  // normalize L
            //     float NdotL = max(dot(i.normal, L), 0);

            //     // now, we are being illuminated by the light ... 
            //     DEBUG_SHOW(kShowLightDistance, V_TO_F4(distToLight), _DebugDistScale)
            //     // now, let's do shadow compuration
            //     float4 wcPt = tex2D(_ShadowMap, i.lightNDC);
            //     float distFromMap = wcPt.a;  // this is distance
            //     DEBUG_SHOW(kShowMapDistance, V_TO_F4(distFromMap), _DebugDistScale)
            //     DEBUG_SHOW(kShowMapWC, wcPt, _DebugDistScale)              
                
            //     distFromMap += _DepthBias;  // push slightly outward to avoid self-shadowing
            //     DEBUG_SHOW(kShowMapDistanceWithBias, V_TO_F4(distFromMap), _DebugDistScale)
                                
            //     if (distToLight > distFromMap) { // in shadow!
            //         NdotL *= 0.1;
            //         DEBUG_SHOW(kShowShadowInRed, float4(1, 0, 0, 1), 1)
            //     }               

            //     return float4(0.1, 0.1, 0.1, 0) + (col * NdotL);  // so will not be completely black
            // }
            ENDCG
        }
    }
}
