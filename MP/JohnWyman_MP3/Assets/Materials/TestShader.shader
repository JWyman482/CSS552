Shader "Unlit/TestShader"
{
    Properties
    {
        _VPoint("VPoint", Vector) = (0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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

            struct OutputFromFragmentShader {
                float4 color : SV_Target;
            };


            v2f vert (appdata v)
            {
                v2f o;
                float4 p = v.vertex;
                
                p = mul(unity_ObjectToWorld, p);            // Transform: To world
                p = mul(UNITY_MATRIX_V, p);                 // Transform: To eye space
                p = mul(UNITY_MATRIX_P, p);                 // Transform: To perspective

                o.vertex = p;
                return o;
            }

            OutputFromFragmentShader frag (v2f i) 
            {
                OutputFromFragmentShader output;
                output.color = float4(1, 0, 0, 1);
                return output;
            }
            ENDCG
        }
        
        Pass
        {
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

            struct OutputFromFragmentShader {
                float4 color : SV_Target;
            };

            float3 _VPoint;

            v2f vert(appdata v)
            {
                v2f o;
                float4 p = v.vertex;
                float w = 0.5 * (1 + _CosTime.z);
                
                //p.xyz += _VPoint;
                p = mul(unity_ObjectToWorld, p);            // Transform: To world
                /*float3 OCVPoint = _VPoint + p.xyz;
                p.xyz += w * (OCVPoint - p.xyz);
                */
                p = mul(UNITY_MATRIX_V, p);                 // Transform: To eye space
                float3 ECVPoint = float3(0, 0, -0.3);
                p.xyz += w * (ECVPoint - p.xyz);
                
                p = mul(UNITY_MATRIX_P, p);                 // Transform: To perspective

                o.vertex = p;
                return o;
            }

            OutputFromFragmentShader frag(v2f i)
            {
                OutputFromFragmentShader output;
                output.color = float4(0, 1, 0, 1);
                return output;
            }
            ENDCG
        }
    }
}
