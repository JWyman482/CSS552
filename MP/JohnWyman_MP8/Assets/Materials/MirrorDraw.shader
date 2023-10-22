Shader "Unlit/MirrorDraw"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }
    SubShader  // Draw Objects in Mirror (referencing to Stencil)
    {
        Tags { "RenderType"="Opaque" "MyReflection" = "Object"}
        LOD 100
        Cull Off

        Pass
        {
            
            Stencil {
                Ref 1
                Comp Equal
            } 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "./CommonDataStruct.cginc"
            #include "./CommonVShader.cginc"
            int _ShaderMode;
            float4 frag (v2f i) : SV_Target
            {
                if ((_ShaderMode & 128) == 0) {
                    discard;
                }
                // sample the texture
                float4 col = float4(0.9, 0.7, 0.7, 1.0);
                if ((i.uv.x != 0) && (i.uv.y != 0))
                    col = tex2D(_MainTex, i.uv);
                float3 L = normalize(_LightPos - i.worldPos);
                float NdotL = max(0.1, dot(i.normal, L)); // don't clam everything off 
                float4 c = col * NdotL;
                return float4(c.xyz, 1);
            }
            
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" 
               "MyReflection" = "Mirror"   
               "Queue" = "Geometry-1"}
               // Draws the  "Mirror" object
               // Draw _BEFORE_ "Geometry" (switch on Stencil)
        LOD 100
        Cull Off

        Pass // Drawing the mirror (switch on stencil)
        {
            Stencil {
                Ref 1
                Comp Always
                Pass Replace
            }
            ZWrite Off  // do not leave foot print in Z-buffer
                        // Remember, MirrorCam is "behind the mirror"
                        //           If Z-buffer write is on, will occlude everything!


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            float4 _MirrorColor;

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

            v2f vert (appdata v)
            {
                v2f output;
                
                float4 p = mul(unity_ObjectToWorld, v.vertex);  // objcet to world
                output.worldPos = p.xyz;  // p.w is 1.0 at this poit
                p = mul(UNITY_MATRIX_V, p);  // To view space
                output.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
                
                output.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));  // if scaled and ignore translation
                        // Transpose of Inversed(unity_ObjectToWorld)
                output.uv = v.uv;
                return output;            
            }
            
            fixed4 frag (v2f input) : SV_Target
            {
                // sample the texture
                float4 texColor = float4(1, 1, 1, 1);
                if (FlagIsOn(kTexture))
                    texColor = tex2D(_MainTex, input.uv);

                float4 shadedResult = float4(0, 0, 0, 1);
                if (FlagIsOn(kAmbient))
                    shadedResult = float4(_Ka.xyz, 1);

                for (int i = 0; i < kNumLights; i++) {
                    if (LightState[i] != eLightOff)
                        shadedResult += PhongIlluminate(_CameraPosition, input.worldPos, i, input.normal, texColor);
                }

                return shadedResult + _MirrorColor;
            }
            ENDCG
        }
    }
}
