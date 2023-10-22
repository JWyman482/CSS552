Shader "Unlit/ProjectionMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass 
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "CommonDataStruct.cginc"
            
            float4x4 _WorldToProjectionNDC; // from World to the projector's NDC

            int _TexFlag;
            static const int uTile = 1;
            static const int uRepeat = 2;
            static const int uMirror = 4;
            static const int uBound = 8;
            static const int vTile = 16;
            static const int vRepeat = 32;
            static const int vMirror = 64;
            static const int vBound = 128;

            int FlagIsOn(int flag) {
                return ((_TexFlag & flag) != 0);
            }

            float4 _TexMapSettings;
            float4 _BoundColor;

            v2f vert (appdata v)
            {
                v2f o;
                float4 p = mul(unity_ObjectToWorld, v.vertex);  // objcet to world
                o.worldPos = p.xyz;  // p.w is 1.0 at this poit

                float4 projectionNDC = mul(_WorldToProjectionNDC, p);
                o.uv = ((projectionNDC.xy / projectionNDC.w) + 1) * 0.5;

                p = mul(UNITY_MATRIX_V, p);  // To view space
                o.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
                            
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = float4(0.9, 0.7, 0.7, 1.0);
                float3 L = normalize(_LightPos - i.worldPos);
                float NdotL = max(0.1, dot(i.normal, L)); // don't clam everything off 

                if ((i.uv.x >= 0) && (i.uv.x <= 1) &&
                    (i.uv.y >= 0) && (i.uv.y <= 1)) {

                    /* Pure Setting */
                    i.uv.xy *= _TexMapSettings.xy;
                    i.uv.xy += _TexMapSettings.zw;
                    
                    if ((i.uv.x < 0) || (i.uv.x > 1)) 
                    {
                        if (FlagIsOn(uRepeat)) i.uv.x = 1;
                        if (FlagIsOn(uBound)) return _BoundColor * NdotL;
                        if (FlagIsOn(uMirror)) {
                            int anInt = trunc(i.uv.x);
                            float aFloat = i.uv.x - anInt;
                            if ((anInt % 2) == 0) i.uv.x = aFloat;      // If second repetition, float portion
                            else i.uv.x = 1 - aFloat;
                        }
                    }
                    
                    if ((i.uv.y < 0) || (i.uv.y > 1)) 
                    {
                        if (FlagIsOn(vRepeat)) i.uv.y = 1;
                        if (FlagIsOn(vBound)) return _BoundColor * NdotL;
                        if (FlagIsOn(vMirror)) {
                            int anInt = trunc(i.uv.y);
                            float aFloat = i.uv.y - anInt;
                            if ((anInt % 2) == 0) i.uv.y = aFloat;      // If second repetition, float portion
                            else i.uv.y = 1 - aFloat;
                        }
                    }

                    col = tex2D(_MainTex, i.uv) * 1.5;
                    
                }

                return col * NdotL;
            }

            ENDCG
        }
    }
}
