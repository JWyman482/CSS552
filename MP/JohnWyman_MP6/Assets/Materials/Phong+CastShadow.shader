Shader "552_Shaders/CastShadow+Phong"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ka ("Ambient", Color) = (0.1, 0.1, 0.1, 1)   // from MyMaterial.cginc
        _Kd ("Diffuse", Color) = (0.7, 0.8, 0.6, 1)
        _Ks ("Specular", Color) = (0.1, 0.1, 0.3, 1)
        _Specularity("n", float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        //Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            // located at: C:\Program Files\Unity\Hub\Editor\2021.3.10f1\Editor\Data\CGIncludes
            #include "UnityCG.cginc"
            #include "MyInclude/MyMaterial.cginc"
            #include "MyInclude/MyLights.cginc"
            #include "MyInclude/MyPhong.cginc"

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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _CameraPosition;

            // Variables provided by Unity:
            //        https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
            //
            DataForFragmentShader VertexProgram(DataFromVertex input)
            {
                DataForFragmentShader output;
                
                float4 p = mul(unity_ObjectToWorld, input.vertex);  // objcet to world
                output.worldPos = p.xyz;  // p.w is 1.0 at this poit
                p = mul(UNITY_MATRIX_V, p);  // To view space
                output.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
                
                output.normal = normalize(mul(input.normal, (float3x3)unity_WorldToObject));  // if scaled and ignore translation
                        // Transpose of Inversed(unity_ObjectToWorld)
                output.uv = input.uv;
                return output;
            }

            float4 FragmentProgram(DataForFragmentShader input) : SV_Target
            {
                // sample the texture
                float4 texColor = float4(1, 1, 1, 1);
                if (FlagIsOn(kTexture))
                    texColor = tex2D(_MainTex, input.uv);

                float4 shadedResult = float4(0, 0, 0, 1);
                if (FlagIsOn(kAmbient))
                    shadedResult = float4(_Ka.xyz, 1) * _Ka.w;

                for (int i = 0; i < kNumLights; i++) {
                    if (LightState[i] != eLightOff)
                        shadedResult += PhongIlluminate(_CameraPosition, input.worldPos, i, input.normal, texColor);
                }

                return shadedResult;
            }
            ENDCG
        }

        Pass
        {  
            Name "Point Shadow"
            Blend SrcAlpha DstAlpha, Zero One
            Stencil {
                Ref 2
                Comp Equal
            }

            CGPROGRAM
            #include "MyInclude/PointPass.cginc"
            ENDCG
        }

        Pass
        {
            Name "Directional Shadow"
            Blend SrcAlpha DstAlpha, Zero One
            Stencil {
                Ref 2
                Comp Equal
            }

            CGPROGRAM
            #include "MyInclude/DirectionPass.cginc"
            ENDCG
        }

        Pass
        {
            Name "Spot Shadow"
            Blend SrcAlpha DstAlpha, Zero OneMinusSrcAlpha
            Stencil {
                Ref 2
                Comp Equal
            }

            CGPROGRAM
            #include "MyInclude/SpotPass.cginc"
            ENDCG
        }
    }
}
