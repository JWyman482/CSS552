Shader "Unlit/Torch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // this is the src of Blit
        _DepthTexture ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

           struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPt : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                float4 p = v.vertex;
                p = mul(unity_ObjectToWorld, p);
                o.worldPt = p.xyz;
                p = mul(UNITY_MATRIX_V, p);
                p = mul(UNITY_MATRIX_P, p);
                o.vertex = p;
                //o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            float _invWidth;    // in Normalized space
            float _invHeight;   // width and height of each pixel

            // lens specifics
            float _inFocusN, _inFocusF;
            sampler2D _DepthTexture;   // from our own DepthShader

            // Torch Settings
            float _TorchFar;
            float _TorchRadius;
            float3 _TorchPosition;


            // For fog modes and debugging
            uint _torchFlag;
            static const int kShowDebugInFocus = 1;
            static const int kShowDebugFocusNF = 2;
            static const int kShowDebugStages = 4;
            static const int kShowDebugBlend = 8;
            
            #include "BlurKernel.cginc"
            
            #define CHECK_DEBUG(FLAG, DEBUG_ACTION) {       \
                if (_lensFlag & FLAG) {                     \
                    return DEBUG_ACTION;                    \
                }                                           \
            }

            //
            float4 frag (v2f fromV) : SV_Target
            {   
                float4 x = tex2D(_DepthTexture, fromV.uv);
                float3 v = fromV.worldPt;

                float4 c1 = tex2D(_MainTex, fromV.uv);
                //float d = distance(tp, v);
                float d = distance(_TorchPosition, v);

                if (d < _TorchRadius)
                    return c1;
                else {
                    float n = d - _TorchRadius;
                    float f = _TorchFar - _TorchRadius;
                    float blend = smoothstep(0.0, 1.0, 1.0 - (n * n) / (f * f));
                    c1 = c1 * blend + filter_15(fromV.uv) * (1 - blend);
                    return c1;
                }

                //float f = x.a;  //  remember our DepthShader records distance to camera in the alpha channel
                //if (f <= 0)
                //    f = _inFocusF + 1; // background, assume at infinity

                //float delta = 0;
                //if (f >= _inFocusN) {
                //    if (f <= _inFocusF) {
                //        // clear!
                //        CHECK_DEBUG(kShowDebugInFocus, float4(0, 1, 0, 1))
                //        return tex2D(_MainTex, fromV.uv);
                //    } else {
                //        CHECK_DEBUG(kShowDebugFocusNF, float4(1, 0, 0, 1))
                //        delta = f - _inFocusF;
                //    }
                //} else {
                //    CHECK_DEBUG(kShowDebugFocusNF, float4(0, 0, 1, 1))
                //    delta = _inFocusN - f;
                //}

                //float a = _inFocusF-_inFocusN;
                //float blend = delta/a; // blend is a linear percentage of how far from in-focus distance
                //CHECK_DEBUG(kShowDebugBlend, float4(blend, blend, blend, 1))

                //float4 c1;
                //if (blend < a) {
                //    CHECK_DEBUG(kShowDebugStages, float4(0.5, 0.5, 0.5, 1))
                //    c1 = filter_5(fromV.uv);
                //} else {
                //    CHECK_DEBUG(kShowDebugStages, float4(0, 0, 0, 1))
                //    c1 = filter_15(fromV.uv);
                //}

                //return c1;                
            }
            ENDCG
        }
    }
}
