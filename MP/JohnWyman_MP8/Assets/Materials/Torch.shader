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
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            float _invWidth;    // in Normalized space
            float _invHeight;   // width and height of each pixel

            // torch
            float3 _torchPosition;
            float _torchRadius;
            float _torchFar;
            float _torchFarIntensity;

            #define VERY_FAR 3

            sampler2D _DepthTexture;   // from our own DepthShader

            // For fog modes and debugging
            uint _torchFlag;
            static const int kShowDebugShowClear = 1;
            static const int kShowDebugBlend = 2;
            static const int kShowInvertedEffect = 0x20;
            
            #include "./MyInclude/BlurKernel.cginc"
            
            #define CHECK_DEBUG(FLAG, DEBUG_COLOR) {        \
                if (_torchFlag & FLAG) {                    \
                    return DEBUG_COLOR;                     \
                }                                           \
            }

            #define CHECK_REVERSE(NORMAL, REVERSE) {        \
                if (_torchFlag & kShowInvertedEffect) {     \
                    return REVERSE;                         \
                } else {                                    \
                    return NORMAL;                          \
                }                                           \
            }

            #define CLEAR tex2D(_MainTex, fromV.uv)
            #define FAR   filter_15(fromV.uv)*_torchFarIntensity

            //
            float4 frag (v2f fromV) : SV_Target
            {   
                float4 x = tex2D(_DepthTexture, fromV.uv);

                float r = length(x.xyz-_torchPosition);
                if (x.a <= 0)  // this is background
                    r = r * VERY_FAR; // background, assume at infinity              

                if (r < _torchRadius) {  // clear!
                    CHECK_DEBUG(kShowDebugShowClear, float4(0, 1, 0, 1))
                    CHECK_REVERSE(CLEAR, FAR)
                }

                float n = (r-_torchRadius);
                float f = (_torchFar-_torchRadius);
                float w = 1-(n*n)/(f*f);
                float blend = smoothstep(0, 1, w);

                if (_torchFlag & kShowInvertedEffect)
                    blend = 1 - blend;

                CHECK_DEBUG(kShowDebugBlend, float4(blend, blend, blend, 1))
                return blend * CLEAR + (1-blend) * FAR;
            }
            ENDCG
        }
    }
}
