Shader "Unlit/Fog"
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

            // Fog specifics
            float _fogDensity;   // extinction coefficient (or density)
            float4 _fogColor;
            float _fogHeight;
            float _fogDenom;
            sampler2D _DepthTexture;   // from our own DepthShader

            // For fog modes and debugging
            uint _flag;
            static const int kShowDebugNotInFog = 1;
            static const int kShowDebugBlend = 2;
            static const int kShowLinearFog = 0x20;
            static const int kFogOverBackground = 0x40;
            
            #define CHECK_DEBUG(FLAG, DEBUG_ACTION) {   \
                if (_flag & FLAG)                       \
                    return DEBUG_ACTION;                \
            }

            // https://learn.microsoft.com/en-us/windows/win32/direct3d9/fog-formulas
            float4 frag (v2f fromV) : SV_Target
            {   
                float4 c1 = tex2D(_MainTex, fromV.uv);
                float4 p = tex2D(_DepthTexture, fromV.uv);

                if (!(_flag & kFogOverBackground)) {
                    if (p.a <= 0)   // this is background pixel!
                        return c1;  // do not fog it!
                }

                float h = p.y;  // use y as height
                if (h >= _fogHeight) {
                    CHECK_DEBUG(kShowDebugNotInFog, float4(1, 0, 0, 1));
                    return c1;
                }
                
                float blend;
                float d = (_fogHeight - h) / _fogDenom;
                if (_flag & kShowLinearFog)
                    blend = max(0, 1-d);
                else 
                    blend = exp(-_fogDensity * d);

                CHECK_DEBUG(kShowDebugBlend, float4(blend, blend, blend, 1))
                c1 = c1 * blend + _fogColor * (1-blend);
                

                return c1;
            }
            ENDCG
        }
    }
}