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
            float _fogHeight;
            float _fogDenominator;
            float4 _fogColor;
            sampler2D _DepthTexture;   // from our own DepthShader

            // For fog modes and debugging
            uint _flag;
            static const int kShowDebugNear = 1;
            static const int kShowDebugBlend = 2;
            
            // For fog settings
            uint _fogSettings;
            static const int kFogLinear = 1;
            static const int kFogBackground = 2;

            #define CHECK_DEBUG(FLAG, DEBUG_ACTION) {   \
                if (_flag & FLAG)                       \
                    c1 = DEBUG_ACTION;                  \
            }

            inline int FlagIsOn(int flag) {
                return ((_fogSettings & flag) != 0);
            }

            // https://learn.microsoft.com/en-us/windows/win32/direct3d9/fog-formulas
            float4 frag(v2f fromV) : SV_Target
            {
                float blend;
                float4 c1 = tex2D(_MainTex, fromV.uv);
                float4 x = tex2D(_DepthTexture, fromV.uv);

                float d = x.a;  //  remember our DepthShader records distance to camera in the alpha channel
                float h = x.y;



                // Handling the background
                if (d <= 0) {
                    if (!FlagIsOn(kFogBackground))
                        return c1;
                    else
                        h = 0;
                }
                    
                
                d = (_fogHeight - h) / _fogDenominator;

                if (FlagIsOn(kFogLinear)) 
                    blend = max(0, 1 - d);
                else 
                    blend = exp(-_fogDensity * d);

                c1 = c1 * blend + _fogColor * (1-blend);
                
                CHECK_DEBUG(kShowDebugBlend, (h > _fogHeight) ? c1 : float4(blend, blend, blend, 1))
                CHECK_DEBUG(kShowDebugNear, (h > _fogHeight) ? float4(1, 0, 0, 1) : c1)

                return c1;
            }
            ENDCG
        }
    }
}
