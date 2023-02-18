Shader "552_Shaders/RecShadow+Phong"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ka ("Ambient", Color) = (0.1, 0.1, 0.1, 1)   // from MyMaterial.cginc
        _Kd ("Diffuse", Color) = (0.7, 0.8, 0.6, 1)
        _Ks ("Specular", Color) = (0.1, 0.1, 0.3, 1)
        _Specularity("n", float) = 1.0

            // Global control on LightLoader
        // _ShaderMode("Mode", int) = 0
            // Bits: On (yes) or Off (no)
            //  All off: returns black
            //   0: Texture   (1)
            //   1: Ambient   (2)
            //   2: Diffuse   (4)
            //   3: Specular  (8)
            //   4: Distance Attenuation (16)
            //   5: Angular Attenuation (32)
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

            // https://docs.unity3d.com/Manual/SL-Stencil.html
            // Write only if Stencil has content of 2
            // Assume the shadow receiver has rendered and set Stencil Psitions to 2
            Stencil {
                Ref 2
                Comp Equal
                // Pass Keep
            }

            // project Vertex to the plane
            // LightPos to p is a line
            //    l(t) = LightPos + t (v - LightPos)
            // Intersection with the receiver plane:
            //    _Normal dot l(t) - D = 0
            //          t = (D - (dot(n, LightPos)))  / (dot(n, (v - LightPos)))
            //    n is _Normal
            //    v is vertex position


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float3 _LightPos;  // in world space
            float3 _Normal; // normal of plane
            float _D; // D of plane
            float4 _ShadowColor; // color of the shadow
        
            v2f vert (appdata input)
            {
                v2f o;
                float4 p = input.vertex;

                p = mul(unity_ObjectToWorld, p);  // objcet to world

                // projection computation must e performed in world space
                float3 Vl = (p.xyz - _LightPos);
                float t = 0.99 * (_D - (dot(_Normal, _LightPos)))  / (dot(_Normal, Vl));
                        // fudge a little to not lie right on top of the receiver
                        // IF light is on the plane, Vl will be zero!! The shader will crash!

                p = float4(_LightPos + t * Vl, 1);

                p = mul(UNITY_MATRIX_V, p);  // To view space
                p = mul(UNITY_MATRIX_P, p);  // Projection 
                o.vertex = p;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return _ShadowColor;  // color of shadow
            }
            ENDCG
        }
    }
}
